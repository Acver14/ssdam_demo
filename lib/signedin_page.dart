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

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

SignedInPageState pageState;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
var _flutterLocalNotificationsPlugin;

final List<String> eventList = ['assets/event/event_demo.png'];

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
  int _tickets;
  bool _loaded = false;
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
    DateTime tmpTime = DateTime.now();
    log.d('before: ${tmpTime}');
    if (tmpTime.hour > 8 && tmpTime.hour < 18) {
      if (tmpTime.hour == 18 && tmpTime.minute > 29) {
        reservationInfo.setReservationTime(
            DateTime(tmpTime.year, tmpTime.month, tmpTime.day + 1, 9, 0, 0));
      } else {
        reservationInfo.setReservationTime(tmpTime.add(Duration(minutes: 30)));
      }
    } else if (tmpTime.hour > 17) {
      reservationInfo.setReservationTime(
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day + 1, 9, 0, 0));
    } else if (tmpTime.hour < 9) {
      reservationInfo.setReservationTime(
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day + 1, 9, 0, 0));
    }
    log.d(reservationInfo.getReservationTime());
    log.d(reservationInfo.getAddress());
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

  Future<Map<String, dynamic>> Loading() async {
    Map<String, dynamic> _user_info = null;
    await fp.setUserInfo();
    _user_info = fp.getUserInfo();
    reservationInfo.setInitialInfo(
        fp.getUser().displayName, fp.getUser().uid, fp.getUser().email);
    if (_user_info != null) {
      return _user_info;
    }
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    reservationInfo.setInitialInfo(
        fp.getUser().displayName, fp.getUser().uid, fp.getUser().email);
    Constant.setTimeRange(9, 18);
    Constant.setMinuteRange(0, 59);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
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
          SizedBox(
            height: statusBarHeight,
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: grid_height * 3,
              reverse: true,
              initialPage: 0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
            ),
            items: eventSliders,
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
                          _tickets = snapshot.data['tickets'];
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
                    onPressed: reservationBtn,
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
            KopoModel model = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Kopo(),
              ),
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
                        TextField(
                          controller: detailAddressCont,
                        )
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
                      ],
                    ));
              }
            }
          },
        ), // input address
        ReservationButton(
            text: DateFormat('yyyy년 MM월 dd일 kk시 mm분').format(
                reservationInfo.getReservationTime() ??
                    DateTime.now().add(Duration(minutes: 30))),
            onPressed: () {
              print('pressed time button');
              showDatePicker(
                      context: context,
                      initialDate: reservationInfo.getReservationTime() == null
                          ? DateTime.now()
                          : reservationInfo.getReservationTime(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)))
                  .then((date) {
                setState(() {
                  if (date != null) reservationInfo.setReservationTime(date);
                  log.d(reservationInfo.getReservationTime());
                  print(reservationInfo.getReservationTime());

                  DateTime t = DateTime.now().add(Duration(minutes: 30));
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: t.hour,
                      minute: t.minute,
                    ),
                  ).then((time) async {
                    setState(() {
                      if (time != null) {
                        if ((time.hour > 9 && time.hour < 13) ||
                            (time.hour > 18 && time.hour < 20)) {
                          DateTime tmp = reservationInfo.getReservationTime();
                          reservationInfo.setReservationTime(DateTime(tmp.year,
                              tmp.month, tmp.day, time.hour, time.minute));
                        }
                        print(time.hour.toString());
                      }
                      print('reservationTime: ${reservationInfo
                          .getReservationTime()}');
                    }
                    );
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
                              '예약 가능 시간이 아닙니다.\n 예약 가능 시간은 오전 9시부터 13시까지, 18시부터 20시 사이입니다.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ));
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
                      reservationInfo
                          .setCustomerRequests(customerRequestCont.text.trim());
                      Navigator.of(context).pop();
                      setRememberRequests(
                          reservationInfo.getCustomerRequests());
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
      if (_tickets > 0) {
        if (reservationInfo
            .getAddress()
            .length > 0) {
          await reservationInfo.saveReservationInfo("collect");
          setState(() {
            _tickets -= 1;
          });
          Firestore.instance
              .collection('userInfo')
              .document(fp
              .getUser()
              .email)
              .updateData({"tickets": _tickets});
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
              ),
              willDisplayWidget: Center(
                  child: Text(
                    '${fp.getUserInfo()['name']}님\n${reservationInfo
                        .getReservationTime()}\n 쓰레기통 수거 예약이 완료되었습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  )));
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
          .email)
          .updateData({"getTrash?": _getTrash});
      log.d('save to firestore');
      return PopupBox.showPopupBox(
          context: context,
          button: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.blue,
            onPressed: () {
              setState(() {
                _icon_button = "close_trash.png";
              });
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

  final List<Widget> eventSliders = eventList
      .map((item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: FlatButton(
                    child: Image.asset(item, fit: BoxFit.cover, width: 1000.0),
                    onPressed: () {},
                  )),
            ),
          ))
      .toList();
}
