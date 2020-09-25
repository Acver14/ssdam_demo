import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customClass/reservatioin_info_class.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:ssdam_demo/customWidget/reservation_button.dart';
import 'package:kopo/kopo.dart';
import 'package:popup_box/popup_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ssdam_demo/customWidget//time_picker_widget.dart';
import 'package:ssdam_demo/customClass/time_picker_format_constant.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ssdam_demo/customWidget/temp_event_image.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

SignedInPageState pageState;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final List<String> eventList = ['assets/event/event_0.png'];

class SignedInPage extends StatefulWidget {
  @override
  SignedInPageState createState() {
    pageState = SignedInPageState();
    return pageState;
  }
}

class SignedInPageState extends State<SignedInPage> {
  FirebaseProvider fp;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _getTrash = false;
  DateTime _reservation_time;
  var _icon_button = "close_trash.png";
  TextEditingController detailAddressCont = TextEditingController();
  TextEditingController customerRequestCont = TextEditingController();
  ReservationInfoProvider reservationInfo = new ReservationInfoProvider();
  var grid_height, grid_width;
  var log = Logger();

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token) {
      print('token:' + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
    getRememberAddr();
    getRememberRequests();
    setReservationTime();
    log.d(reservationInfo.getReservationTime());
    log.d(reservationInfo.getAddress());

    // for local_noti
    var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSetting = IOSInitializationSettings();
    var initializationSettings =
    InitializationSettings(androidSetting, iosSetting);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    log.d('noti??');
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(''),
              content: Text('Payload: $payload'),
            ));
  }

  setReservationTime() {
    DateTime tmpTime = DateTime.now();
    log.d('before: ${tmpTime}');
    if (tmpTime.hour > 8 && tmpTime.hour < 12 ||
        tmpTime.hour > 17 && tmpTime.hour < 19) {
      _reservation_time = tmpTime.add(Duration(hours: 1));
    } else if (tmpTime.hour >= 12 && tmpTime.hour <= 17) {
      _reservation_time =
          DateTime(
              tmpTime.year,
              tmpTime.month,
              tmpTime.day,
              18,
              0,
              0,
              0,
              0);
    } else {
      tmpTime = tmpTime.add(Duration(days: 1));
      _reservation_time =
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day, 9, 0, 0, 0, 0);
    }
    if (_reservation_time.weekday == 6) {
      _reservation_time = _reservation_time.add(Duration(days: 2));
    } else if (_reservation_time.weekday == 7) {
      _reservation_time = _reservation_time.add(Duration(days: 1));
    }
    reservationInfo.setReservationTime(_reservation_time);
  }

  getRememberAddr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reservationInfo.setAddress(prefs.getString("recentlyAddress") ?? "");
      reservationInfo
          .setDetailedAddress(prefs.getString("recentlyDetailedAddress") ?? "");
    });
  }

  getRememberRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reservationInfo.setCustomerRequests(
          prefs.getString("recentlyCustomerRequests") ?? "");
    });
  }

  setRememberAddr(String addr, String dAddr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("recentlyAddress", addr ?? '');
    prefs.setString("recentlyDetailedAddress", dAddr ?? '');
  }

  setRememberRequests(String rq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("recentlyCustomerRequests", rq ?? '');
  }

  setDeviceToken() async {
    await Firestore.instance
        .collection('fcmTokenInfo')
        .document(fp
        .getUser()
        .uid)
        .setData({'token': fp.token});
    log.d('device token save');
  }

  Future<Map<String, dynamic>> Loading() async {
    Map<String, dynamic> _user_info = null;
    await fp.setUserInfo();
    await setDeviceToken();
    _user_info = fp.getUserInfo();
    reservationInfo.setInitialInfo(fp.getUser().uid, fp.getUser().email);
    print(fp.getUser().toString());
    if (_user_info != null) {
      return _user_info;
    }
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    // Constant.setTimeRange(9, 18);
    // Constant.setMinuteRange(0, 59);
    final double statusBarHeight = MediaQuery
        .of(context)
        .padding
        .top;
    grid_height = getDisplayHeight(context) / 10;
    grid_width = getDisplayWidth(context) / 10;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarOpacity: 1.0,
      ),
      drawer: sideDrawer(context, fp),
      body: Wrap(
        children: <Widget>[
          Container(
              child: Padding(padding: EdgeInsets.only(top: statusBarHeight))
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: grid_height * 3,
              reverse: true,
              initialPage: 0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
            ),
            items: eventList
                .map((item) =>
                Container(
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: FlatButton(
                          child: Image.asset(
                              item, fit: BoxFit.cover, width: 1000.0),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => eventPage(),
                              ), //MaterialPageRoute
                            );
                          },
                        )),
                  ),
                )).toList(),
          ),
          Divider(
            thickness: 5,
          ),
          Container(
              margin: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Center(
                child: Column(children: <Widget>[
                  FutureBuilder(
                      future: Loading(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        log.d(snapshot.data);
                        if (snapshot.hasData && !snapshot.data.isEmpty) {
                          _getTrash = snapshot.data['getTrash?'];
                          return widgetContainerForReservation();
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 15),
                            ),
                          );
                        } else {
                          return widgetLoading();
                        }
                      }),
                  SizedBox(
                    height: grid_height / 6,
                  ),
                  MaterialButton(
                    onPressed: () =>
                        reservationBtn(),
                    color: COLOR_SSDAM,
                    textColor: Colors.white,
                    minWidth: grid_height * 3.7,
                    height: grid_height * 3.7,
                    child: Image.asset(
                      'assets/icon/${_icon_button}',
                      width: grid_height * 2.7,
                      height: grid_height * 2.7,
                      fit: BoxFit.fill,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  )
                ]),
              ))
        ],
      ),
    );
  }

  Widget widgetContainerForReservation() {
    return Container(
        child: Column(
      children: <Widget>[
        ReservationButton(
          text: reservationInfo.getAddress().length != 0
              ? '${reservationInfo.getAddress()} ${reservationInfo.getDetailedAddress()}'
              : '어디로 가져다 드릴까요?',
          onPressed: () async {
            KopoModel model = await Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => Kopo()),
            );
            //print(model.toJson());
            if (model != null) {
              if (model.address.toString().indexOf('광진구') == -1) {
                await PopupBox.showPopupBox(
                    context: context,
                    button: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.blue,
                      child: Text(
                        'Ok',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    willDisplayWidget: Column(
                      children: <Widget>[
                        Text(
                          '죄송합니다.\n현재 서비스는 광진구에서만 진행하고 있습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ));
              }
              else {
                setState(() {
                  reservationInfo.setAddress('${model.address}');
                });
                log.d("show?");
                await PopupBox.showPopupBox(
                    context: context,
                    button: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.blue,
                      child: Text(
                        'Ok',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        reservationInfo
                            .setDetailedAddress(detailAddressCont.text.trim());
                        Navigator.of(context).pop();
                        setRememberAddr(
                            reservationInfo.getAddress(),
                            detailAddressCont.text);
                      },
                    ),
                    willDisplayWidget: Column(
                      children: <Widget>[
                        Text(
                          '상세주소를 입력해주세요.\n(상세주소가 없을 경우 생략)',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        TextField(
                          controller: detailAddressCont,
                        )
                      ],
                    ));
              }
            }
          },
        ), // input address
        ReservationButton(
            text: DateFormat('yyyy년 MM월 dd일 kk시 mm분').format(
              //reservationInfo.getReservationTime() ??
                _reservation_time),
            onPressed: () {
              print('pressed time button');
              DateTime initial_date = DateTime.now();
              switch (initial_date.weekday) {
                case 7:
                  initial_date.add(Duration(days: 1));
                  break;
                case 6:
                  initial_date.add(Duration(days: 2));
                  break;
                default:
                  break;
              }
              showDatePicker(
                context: context,
                initialDate: _reservation_time,
                firstDate: initial_date,
                lastDate: initial_date.add(Duration(days: 30)),
                selectableDayPredicate: (DateTime val) =>
                    val.weekday == 7 || val.weekday == 6 ? false : true,
              ).then((date) {
                setState(() {
                  if (date != null) {
                    _reservation_time = DateTime(
                        date.year, date.month, date.day, _reservation_time.hour,
                        _reservation_time.minute);
                  }
                  reservationInfo.setReservationTime(_reservation_time);

                  DateTime t = DateTime.now().add(Duration(hours: 1));
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: t.hour,
                      minute: t.minute,
                    ),
                  ).then((time) {
                    setState(() {
                      if (time != null) {
                        log.d(time.hour.toString());
                        if ((time.hour >= 9 && time.hour < 13) ||
                            (time.hour >= 18 && time.hour < 20)) {
                          log.d(DateTime
                              .now()
                              .hour);
                          DateTime tmp = _reservation_time;
                          if (DateTime(tmp.year,
                              tmp.month, tmp.day, time.hour,
                              time.minute).compareTo(DateTime.now()) > 0) {
                            reservationInfo.setReservationTime(
                                DateTime(tmp.year,
                                    tmp.month, tmp.day, time.hour,
                                    time.minute));
                            _reservation_time =
                                reservationInfo.getReservationTime();
                            log.d('${reservationInfo
                                .getReservationTime()} ${_reservation_time}');
                          }
                          return;
                        }
                        else {
                          PopupBox.showPopupBox(
                              context: context,
                              button: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.blue,
                                child: Text(
                                  'Ok',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () {
                                  setState(() {
                                    this.setReservationTime();
                                    print(_reservation_time);
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              willDisplayWidget: Column(
                                children: <Widget>[
                                  Text(
                                    '예약 가능 시간이 아닙니다.\n 예약 가능 시간은 \n09:00 ~ 12:59,\n18:00 ~ 19:59입니다.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ));
                        }
                      }
                      reservationInfo.setReservationTime(_reservation_time);
                      print('reservationTime: ${reservationInfo
                          .getReservationTime()}');
                    }
                    );
                  });
                });
              });

              // TimePickerSpinner(
              //     is24HourMode: true,
              //     onTimeChange: (time) {
              //       setState(() {
              //         _date_time = _date_time.add(
              //             Duration(hours: time.hour, minutes: time.minute));
              //       });
              //     });
              log.d("예약 요청 시각 : ${reservationInfo.getReservationTime()}");
            }),

        ReservationButton(
            text: reservationInfo.getCustomerRequests().length != 0
                ? '${reservationInfo.getCustomerRequests()}'
                : '현관 비밀번호가 있으신가요?',
            onPressed: () async {
              await PopupBox.showPopupBox(
                  context: context,
                  button: MaterialButton(
                    minWidth: grid_width * 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: COLOR_SSDAM,
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        reservationInfo.setCustomerRequests(
                            customerRequestCont.text.trim());
                        setRememberRequests(
                            reservationInfo.getCustomerRequests());
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  willDisplayWidget: Column(
                    children: <Widget>[
                      Text(
                        '요청 사항을 입력해주세요.\n(현관 비밀번호 등)',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      TextField(
                        controller: customerRequestCont,
                      )
                    ],
                  ));
            }),
      ],
    ));
  }

  Future<Widget> reservationBtn() async {
    reservationInfo.setCustomerRequests(customerRequestCont.text.trim());
    setRememberRequests(reservationInfo.getCustomerRequests());
    reservationInfo.setApplicationTime(DateTime.now());
    if (fp.getUserInfo()["getTrash?"]) {
      if (fp.getUserInfo()['tickets'] + fp.getUserInfo()['p_ticket'] > 0) {
        if (reservationInfo.getAddress().length > 0) {
          return PopupBox.showPopupBox(
            context: context,
            button: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: COLOR_SSDAM,
                  child: Text(
                    '취소',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                MaterialButton(
                  //minWidth: grid_width * 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    ),
                    color: COLOR_SSDAM,
                    child: Text(
                      '확인',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () async {
                      // setState(() {
                      //   _tickets -= 1;
                      // });
                      if (fp.getUserInfo()['p_ticket'] > 0) {
                        Firestore.instance
                            .collection('userInfo')
                            .document(fp
                            .getUser()
                            .uid)
                            .updateData(
                            {"p_ticket": fp.getUserInfo()['p_ticket'] - 1});
                        reservationInfo.setPromotion(true);
                      }
                      else {
                        Firestore.instance
                            .collection('userInfo')
                            .document(fp
                            .getUser()
                            .uid)
                            .updateData(
                            {"tickets": fp.getUserInfo()['tickets'] - 1});
                        reservationInfo.setPromotion(false);
                      }
                      reservationInfo.setName(fp.getUserInfo()['name']);
                      await reservationInfo.saveReservationInfo("collect");
                      // setState(() async {
                      //   await Loading();
                      // });
                      _showNotificationAtTime((reservationInfo
                          .getApplicationTime()
                          .millisecondsSinceEpoch
                          - DateTime(
                              DateTime
                                  .now()
                                  .year,
                              DateTime
                                  .now()
                                  .month,
                              1,
                              0,
                              0,
                              0,
                              0).millisecondsSinceEpoch),
                          reservationInfo.getReservationTime(),
                          Duration(minutes: 30));
                      Navigator.pop(context);
                      print('예약 완료');
                      return PopupBox.showPopupBox(
                        context: context,
                        button: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        willDisplayWidget: Center(
                            child: Text(
                              '${fp.getUserInfo()['name']}님\n'
                                  '${reservationInfo.getReservationTime()}\n'
                              //'${reservationInfo.getAddress()} ${reservationInfo.getDetailedAddress()}\n'
                                  '예약이 완료되었습니다.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black),
                            )),
                      );
                    },
                  ),
                ],
              ),
            willDisplayWidget: Center(
                child: Text(
                  '${fp.getUserInfo()['name']}님\n'
                      '${reservationInfo.getReservationTime()}\n'
                      '${reservationInfo.getAddress()} ${reservationInfo
                      .getDetailedAddress()}\n'
                      '쓰레기통 수거 예약 하시겠습니까?',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                )),
          );
        }
        else {
          return PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                minWidth: grid_width * 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: COLOR_SSDAM,
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              willDisplayWidget: Center(
                  child: Text(
                    '주소를 입력해주시기 바랍니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  )));
        }
      } else {
        return PopupBox.showPopupBox(
            context: context,
            button: MaterialButton(
              minWidth: grid_width * 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: COLOR_SSDAM,
              child: Text(
                'Ok',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            willDisplayWidget: Center(
                child: Text(
                  '잔여 이용권이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                )));
      }
    } else {
      await reservationInfo.saveReservationInfo("deliver");
      setState(() {
        _getTrash = true;
        _icon_button = "open_trash.png";
      });
      Firestore.instance
          .collection('userInfo')
          .document(fp
          .getUser()
          .uid)
          .updateData({"getTrash?": _getTrash});
      reservationInfo.setName(fp.getUserInfo()['name']);
      log.d('save to firestore');
      return PopupBox.showPopupBox(
          context: context,
          button: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.blue,
            onPressed: () {
              {
                Navigator.pop(context);
              }
            },
          ),
          willDisplayWidget: new Center(
              child: Text(
                '${fp
                    .getUser()
                    .displayName}님\n${reservationInfo
                    .getReservationTime()}\n 쓰레기통 배송 예약이 완료되었습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )));
    }
  }

  // List<Widget> eventSliders = eventList
  //     .map((item) => Container(
  //           child: Container(
  //             margin: EdgeInsets.all(5.0),
  //             child: ClipRRect(
  //                 borderRadius: BorderRadius.all(Radius.circular(5.0)),
  //                 child: FlatButton(
  //                   child: Image.asset(item, fit: BoxFit.fill, width: 1000.0),
  //                   onPressed: () {
  //                     Navigator.push(
  //                       MaterialPageRoute(
  //                         builder: (context) => SignInPage(),
  //                       ), //MaterialPageRoute
  //                     );
  //                   },
  //                 )),
  //           ),
  // )).toList();

  Future _showNotificationAtTime(int id, DateTime target_time,
      Duration alert_term) async {
    var scheduledNotificationDateTime = target_time.subtract(alert_term);

    //reservationInfo.getReservationTime().subtract(alert_term);      알람까지 지연시간

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'default', 'your channel description',
        //sound: 'slow_spring_board.aiff',
        importance: Importance.Max,
        priority: Priority.High);

    var iosPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring.board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.schedule(
      id,
      '쓰담 고객님,',
      '${alert_term.inMinutes}분 후 도착 예정입니다!',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: '혹시 쓰레기통을 내놓지 않으셨다면 잊지 말고 내놓아 주시기 바랍니다!',
    );
    log.d('노티 등록 완료');
  }

  Future _showNotificationRepeat() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        //sound: 'slow_spring_board',
        importance: Importance.Max,
        priority: Priority.High
    );

    var iosPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'slow_spring.board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      '반복 Notification',
      '반복 Notification 내용',
      RepeatInterval.EveryMinute,
      platformChannelSpecifics,
      payload: 'Hello Flutter',
    );
  }

  Future _showNotificationWithSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        //sound: 'slow_spring_board',
        importance: Importance.Max,
        priority: Priority.High
    );

    var iosPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'slow_spring.board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iosPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      '심플 Notification',
      '이것은 Flutter 노티피케이션!',
      platformChannelSpecifics,
      payload: 'Hello Flutter',
    );
  }
}

Future cancelNotification(int id) async {
  await _flutterLocalNotificationsPlugin.cancel(id);
  print('노티 취소 완료');
}
