import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:ntp/ntp.dart';
import 'package:image_slider/image_slider.dart';

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

class SignedInPageState extends State<SignedInPage>
    with TickerProviderStateMixin {
  FirebaseProvider fp;
  FirebaseStorage fs = FirebaseStorage.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _getTrash = false;
  DateTime _reservation_time;
  var time_zone;
  DateTime _now;
  var _icon_button = "close_trash.png";
  TextEditingController detailAddressCont = TextEditingController();
  TextEditingController customerRequestCont = TextEditingController();
  ReservationInfoProvider reservationInfo = new ReservationInfoProvider();
  var grid_height, grid_width;
  var log = Logger();
  int event_num = 0;
  var event_info;
  var button_pressed = false;
  var token_save = false;
  List<String> _event_list = new List();
  TabController tabController;
  var _banner_loading = false;
  List<String> events;

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

  setDeviceToken() async {
    await Firestore.instance
        .collection('userInfo')
        .document(fp.getUser().uid)
        .setData({'token': fp.token}, merge: true);
    logger.d('setDeviceToke: ${fp.getUser().uid}, ${fp.token}');
    token_save = true;
  }

  @override
  initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
    getRememberAddr();
    getRememberRequests();
    //setReservationTime();
    //eventSetting();
    // for local_noti
    var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSetting = IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(androidSetting, iosSetting);
    //loadingBanner();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    Timer.periodic(new Duration(minutes: 3), (timer) {
      fp.setUserInfo_notify();
    });
  }

  Future onSelectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text(''),
              content: Text('Payload: $payload'),
            ));
  }

  setReservationTime() async {
    DateTime tmpTime = await NTP.now();
    // if (tmpTime.hour > 8 && tmpTime.hour < 12 ||
    //     tmpTime.hour > 17 && tmpTime.hour < 19) {
    //   _reservation_time = tmpTime.add(Duration(hours: 1));
    // } else if (tmpTime.hour >= 12 && tmpTime.hour <= 17) {
    //   _reservation_time =
    //       DateTime(
    //           tmpTime.year,
    //           tmpTime.month,
    //           tmpTime.day,
    //           18,
    //           0,
    //           0,
    //           0,
    //           0);
    // } else {
    //   tmpTime = tmpTime.add(Duration(days: 1));
    //   _reservation_time =
    //       DateTime(tmpTime.year, tmpTime.month, tmpTime.day, 9, 0, 0, 0, 0);
    // }
    // if (_reservation_time.weekday == 6) {
    //   _reservation_time = _reservation_time.add(Duration(days: 2));
    // } else if (_reservation_time.weekday == 7) {
    //   _reservation_time = _reservation_time.add(Duration(days: 1));
    // }
    // reservationInfo.setReservationTime(_reservation_time);
    if (tmpTime.hour > 19) {
      _reservation_time =
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day + 1, 10, 0);
      time_zone = '10:00';
    }
    else if (tmpTime.hour > 13) {
      _reservation_time =
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day, 20, 0);
      time_zone = '20:00';
    } else if (tmpTime.hour > 9) {
      _reservation_time =
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day, 14, 0);
      time_zone = '14:00';
    } else {
      _reservation_time =
          DateTime(tmpTime.year, tmpTime.month, tmpTime.day, 10, 0);
      time_zone = '10:00';
    }
    if (_reservation_time.weekday == 6) {
      _reservation_time = _reservation_time.add(Duration(days: 2));
      time_zone = '10:00';
    } else if (_reservation_time.weekday == 7) {
      _reservation_time = _reservation_time.add(Duration(days: 1));
      time_zone = '10:00';
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

  Future<Map<String, dynamic>> Loading() async {
    //Map<String, dynamic> _user_info = null;
    // var _getUserInfo = await fp.setUserInfo();
    if (_reservation_time == null) await setReservationTime();
    // while(!_getUserInfo){
    //  _getUserInfo = await fp.setUserInfo();
    // }

    //_now = await NTP.now();
    //_user_info = fp.getUserInfo();
    //logger.d(_getUserInfo);
    if (fp.getUserInfo() == null || fp
        .getUserInfo()
        .length == 0) {
      await fp.setUserInfo();
    }
    reservationInfo.setInitialInfo(fp
        .getUser()
        .uid, fp
        .getUserInfo()['email'], fp.getUserInfo()['phone']);
    if (!token_save) setDeviceToken();
    // if (_getUserInfo) {
    //   return fp.getUserInfo();
    // }
    return fp.getUserInfo();
  }

  Future<List<String>> loadingBanner() async {
    //logger.d(!_banner_loading);
    var ret_list = new List();
    if (!_banner_loading) {
      _banner_loading = true;
      await eventSetting();
      for (int i = 0; i < event_num; i++) {
        var temp = await FirebaseStorage.instance
            .ref()
            .child('banner/event_$i.png')
            .getDownloadURL();
        _event_list.add(temp);
      }
      setState(() {
        tabController =
            new TabController(vsync: this, length: _event_list.length);
      });
    }
    return _event_list;
  }

  Future<void> eventSetting() async {
    //logger.d(event_num);
    if (event_num == 0) {
      event_info = await Firestore.instance.collection('ssdamInfo')
          .document('bannerState')
          .get();
      event_num = event_info.data.length;
    }
    //logger.d(event_num);
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
          FutureBuilder(
              future: loadingBanner(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                logger.d(snapshot.hasData);
                if (snapshot.hasData) {
                  logger.d(snapshot.data);
                  List<String>events = snapshot.data;
                  // return CarouselSlider(
                  //   options: CarouselOptions(
                  //     height: 170,
                  //     reverse: true,
                  //     initialPage: 0,
                  //     autoPlay: true,
                  //     autoPlayInterval: Duration(seconds: 3),
                  //   ),
                  //   items: events // 네트워크 이미지 보류
                  //       .map((item) =>
                  //       Container(
                  //         child: Container(
                  //           margin: EdgeInsets.all(5.0),
                  //           // child: ClipRRect(
                  //           //     borderRadius: BorderRadius.all(
                  //           //         Radius.circular(5.0)),
                  //               child: FlatButton(
                  //                 child: Image.network(
                  //                     item, height: 400, width: 1000.0),
                  //                 onPressed: () {
                  //                   // Navigator.push(
                  //                   //   context,
                  //                   //   MaterialPageRoute(
                  //                   //     builder: (context) => eventPage(),
                  //                   //   ), //MaterialPageRoute
                  //                   // );
                  //                   var idx = events.indexOf(item);
                  //                   launchWebView(
                  //                       'https://' + event_info['event_$idx']);
                  //                 },
                  //               ),
                  //         ),
                  //       )).toList(),
                  // );
                  logger.d(tabController.length);
                  logger.d(events.length);
                  logger.d(events);
                  //if(tabController.length == events.length){
                  return new ImageSlider(

                    /// Shows the tab indicating circles at the bottom
                    showTabIndicator: false,

                    /// Cutomize tab's colors
                    tabIndicatorColor: Colors.lightBlue,

                    /// Customize selected tab's colors
                    tabIndicatorSelectedColor: Color.fromARGB(255, 0, 0, 255),

                    /// Height of the indicators from the bottom
                    tabIndicatorHeight: 16,

                    /// Size of the tab indicator circles
                    tabIndicatorSize: 16,

                    /// tabController for walkthrough or other implementations
                    tabController: tabController,

                    /// Animation curves of sliding
                    curve: Curves.fastOutSlowIn,

                    /// Width of the slider
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,

                    /// Height of the slider
                    height: 200,

                    /// If automatic sliding is required
                    autoSlide: true,

                    /// Time for automatic sliding
                    duration: new Duration(seconds: 3),

                    /// If manual sliding is required
                    allowManualSlide: true,

                    /// Children in slideView to slide
                    children: events.map((String link) {
                      return new FlatButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => eventPage(),
                            //   ), //MaterialPageRoute
                            // );
                            var idx = events.indexOf(link);
                            launchWebView(
                                'https://' + event_info['event_$idx']);
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                link,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                //height: 200,
                                fit: BoxFit.fitWidth,
                              )));
                    }).toList(),
                  );
                  // }
                  // else{
                  //   return Container(
                  //     height: 200,
                  //     child: widgetLoading(),
                  //   );
                  // }
                } else {
                  return Container(
                    height: 200,
                    child: widgetLoading(),
                  );
                }
              }
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
                        //logger.d(snapshot.data);
                        if (snapshot.hasData && !snapshot.data.isEmpty) {
                          _getTrash = snapshot.data['getTrash?'];
                          if (_getTrash) {
                            return widgetViewForCollect();
                          } else {
                            return widgetViewForDeliver();
                          }
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 15),
                            ),
                          );
                        } else {
                          return Container(
                            height: grid_height * 3,
                            child: widgetLoading(),
                          );
                        }
                      }),

                ]),
              ))
        ],
      ),
    );
  }

  Widget widgetViewForCollect() {
    return Column(
      children: [
        widgetContainerForReservation(),
        SizedBox(
          height: grid_height / 6,
        ),
        MaterialButton(
          onPressed: () {
            logger.d(button_pressed);
            reservationBtn_collect();
          },
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
      ],
    );
  }

  Widget widgetViewForDeliver() {
    return Column(
      children: [
        widgetContainerForReservation(),
        SizedBox(
          height: grid_height / 6,
        ),
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                color: COLOR_SSDAM,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                //onPressed: () => reservationBtn_deliver(),
                onPressed: () => reservationBtn_collect(),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                    child: Column(
                      children: [
                        Text('\n쓰담 박스 받기',
                          style: TextStyle(color: Colors.white, fontSize: 18),),
                        Text('\n(20L와 2L 용량의 박스가 배송됩니다.)\n',
                          style: TextStyle(color: Colors.white, fontSize: 15),),
                      ],
                    )
                )
            )
        )
      ],
    );
  }

  Widget widgetContainerForReservation() {
    return Container(
        child: Column(
          children: <Widget>[
            ReservationButton(
              text: reservationInfo
                  .getAddress()
                  .length != 0
                  ? '${reservationInfo.getAddress()} ${reservationInfo
                  .getDetailedAddress()}'
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
                text: '${DateFormat('yyyy/MM/dd').format(
                  //reservationInfo.getReservationTime() ??
                    _reservation_time)}, ${time_zone}',
                onPressed: () async {
                  //print('pressed time button');
                  DateTime initial_date = await NTP.now();
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
                  ).then((date) async {
                    if (date != null) {
                      _reservation_time = DateTime(
                          date.year, date.month, date.day,
                          _reservation_time.hour,
                          _reservation_time.minute);
                    }
                    setState(() {
                      reservationInfo.setReservationTime(_reservation_time);
                    });
                    //DateTime t = initial_date.add(Duration(hours: 1));
                    // showTimePicker(
                    //   context: context,
                    //   initialTime: TimeOfDay(
                    //     hour: t.hour,
                    //     minute: t.minute,
                    //   ),
                    // ).then((time) async {
                    //   logger.d(time);
                    //     if (time != null) {
                    //       if ((time.hour >= 9 && time.hour < 13) ||
                    //           (time.hour >= 18 && time.hour < 20)) {
                    //         DateTime tmp = _reservation_time;
                    //         if (DateTime(tmp.year,
                    //             tmp.month, tmp.day, time.hour,
                    //             time.minute).difference(initial_date) > Duration(minutes: 59)) {
                    //           setState(() {
                    //             reservationInfo.setReservationTime(
                    //                 DateTime(tmp.year,
                    //                     tmp.month, tmp.day, time.hour,
                    //                     time.minute));
                    //             _reservation_time =
                    //                 reservationInfo.getReservationTime();
                    //           });
                    //         }
                    //         else{
                    //           await PopupBox.showPopupBox(
                    //               context: context,
                    //               button: MaterialButton(
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(20),
                    //                 ),
                    //                 color: Colors.blue,
                    //                 child: Text(
                    //                   'Ok',
                    //                   style: TextStyle(fontSize: 20),
                    //                 ),
                    //                 onPressed: () async {
                    //                   // setState(() {
                    //                   //   this.setReservationTime();
                    //                   //   print(_reservation_time);
                    //                   // });
                    //                   await setReservationTime();
                    //                   Navigator.of(context).pop();
                    //                 },
                    //               ),
                    //               willDisplayWidget: Column(
                    //                 children: <Widget>[
                    //                   Text(
                    //                     '예약 가능 시간이 아닙니다.\n 예약 시간은 1시간 이후로 해주십시오.',
                    //                     style: TextStyle(
                    //                         fontSize: 16, color: Colors.black),
                    //                   ),
                    //                 ],
                    //               ));
                    //         }
                    //         return;
                    //       }
                    //       else {
                    //         await PopupBox.showPopupBox(
                    //             context: context,
                    //             button: MaterialButton(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20),
                    //               ),
                    //               color: Colors.blue,
                    //               child: Text(
                    //                 'Ok',
                    //                 style: TextStyle(fontSize: 20),
                    //               ),
                    //               onPressed: () async {
                    //                 // setState(() {
                    //                 //   this.setReservationTime();
                    //                 //   print(_reservation_time);
                    //                 // });
                    //                 await setReservationTime();
                    //                 Navigator.of(context).pop();
                    //               },
                    //             ),
                    //             willDisplayWidget: Column(
                    //               children: <Widget>[
                    //                 Text(
                    //                   '예약 가능 시간이 아닙니다.\n 예약 가능 시간은 \n09:00 ~ 12:59,\n18:00 ~ 19:59입니다.',
                    //                   style: TextStyle(
                    //                       fontSize: 16, color: Colors.black),
                    //                 ),
                    //               ],
                    //             ));
                    //       }
                    //     }
                    //     reservationInfo.setReservationTime(_reservation_time);
                    //     print('reservationTime: ${reservationInfo
                    //         .getReservationTime()}');
                    //   }
                    //   );
                    await PopupBox.showPopupBox(
                        context: context,
                        button: MaterialButton(),
                        willDisplayWidget: Column(
                          children: <Widget>[
                            Text(
                              '수거 시간대를 선택해주십시오.',
                              style: TextStyle(fontSize: 16,
                                  color: Colors.black),
                            ),
                            SizedBox(height: 20,),
                            DropdownButton(
                              value: time_zone,
                              items: [
                                DropdownMenuItem(
                                  child: Text('10:00'),
                                  value: '10:00',
                                ),
                                DropdownMenuItem(
                                  child: Text('14:00'),
                                  value: '14:00',
                                ),
                                DropdownMenuItem(
                                  child: Text('20:00'),
                                  value: '20:00',
                                ),
                              ],
                              onChanged: (value) async {
                                time_zone = value;
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ));
                    _now = await NTP.now();
                    //logger.d(_reservation_time);
                    if (_reservation_time.isBefore(
                        _now.subtract(Duration(minutes: 59)))) {
                      await setReservationTime();
                      setState(() {});
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          willDisplayWidget: Column(
                            children: <Widget>[
                              Text(
                                '현시각 이후로 예약 시간대를 설정해주세요',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ));
                    } else {
                      setState(() {
                        if (time_zone == '10:00') {
                          reservationInfo.setReservationTime(
                              DateTime(_reservation_time.year,
                                  _reservation_time.month,
                                  _reservation_time.day, 10,
                                  0));
                          _reservation_time =
                              reservationInfo.getReservationTime();
                        }
                        else if (time_zone == '14:00') {
                          reservationInfo.setReservationTime(
                              DateTime(_reservation_time.year,
                                  _reservation_time.month,
                                  _reservation_time.day, 14,
                                  0));
                          _reservation_time =
                              reservationInfo.getReservationTime();
                        }
                        else {
                          reservationInfo.setReservationTime(
                              DateTime(_reservation_time.year,
                                  _reservation_time.month,
                                  _reservation_time.day, 20,
                                  0));
                          _reservation_time =
                              reservationInfo.getReservationTime();
                        }
                      });
                    }
                    logger.d(_reservation_time);
                  });

                  // TimePickerSpinner(
                  //     is24HourMode: true,
                  //     onTimeChange: (time) {
                  //       setState(() {
                  //         _date_time = _date_time.add(
                  //             Duration(hours: time.hour, minutes: time.minute));
                  //       });
                  //     });
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

  Future<Widget> reservationBtn_collect() async {
    _now = await NTP.now();
    reservationInfo.setCustomerRequests(customerRequestCont.text.trim());
    setRememberRequests(reservationInfo.getCustomerRequests());
    reservationInfo.setApplicationTime(_now);
    if (fp.getUserInfo()['phone'] == '0') {
      return await PopupBox.showPopupBox(
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
                '마이페이지에서 휴대폰 인증을 해주시기 바랍니다.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )));
    }
    else if (fp.getUserInfo()['tickets'] + fp.getUserInfo()['p_tickets'] +
        fp.getUserInfo()['r_tickets'] > 0) {
      if (reservationInfo
          .getAddress()
          .length > 0 && reservationInfo.getReservationTime().difference(_now) >
          Duration(minutes: 59)) {
        return await PopupBox.showPopupBox(
          context: context,
          button: !button_pressed ? Row(
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
                  if (!button_pressed) {
                    Navigator.pop(context);
                    setState(() {
                      button_pressed = false;
                    });
                  }
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
                  logger.d(button_pressed);
                  if (!button_pressed) {
                    setState(() {
                      button_pressed = true;
                    });
                    reservationInfo.setName(fp.getUserInfo()['name']);
                    logger.d('button pressed');
                    bool reservation_result = await reservationInfo
                        .saveReservationInfo("collect", context);
                    // setState(() async {
                    //   await Loading();
                    // });
                    if (reservation_result) {
                      if (fp.getUserInfo()['r_tickets'] > 0) {
                        Firestore.instance
                            .collection('userInfo')
                            .document(fp
                            .getUser()
                            .uid)
                            .updateData(
                            {"r_tickets": fp.getUserInfo()['r_tickets'] - 1});
                        reservationInfo.setPromotion(false);
                      }
                      else if (fp.getUserInfo()['p_tickets'] > 0) {
                        Firestore.instance
                            .collection('userInfo')
                            .document(fp
                            .getUser()
                            .uid)
                            .updateData(
                            {"p_tickets": fp.getUserInfo()['p_tickets'] - 1});
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
                      _showNotificationAtTime((reservationInfo
                          .getApplicationTime()
                          .millisecondsSinceEpoch
                          - DateTime(
                              _now
                                  .year,
                              _now
                                  .month,
                              1,
                              0,
                              0,
                              0,
                              0).millisecondsSinceEpoch),
                          reservationInfo.getReservationTime(),
                          Duration(minutes: 30));
                      fp.setUserInfo_notify();
                      Navigator.pop(context);
                      print('예약 완료');
                      setState(() {
                        button_pressed = false;
                      });
                      return await PopupBox.showPopupBox(
                        context: context,
                        button: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        willDisplayWidget: Center(
                            child: Text(
                              '${fp.getUserInfo()['name']}님\n'
                                  '${DateFormat('yyyy년 MM월 dd일').format(
                                  _reservation_time)}, ${time_zone}\n'
                              //'${reservationInfo.getAddress()} ${reservationInfo.getDetailedAddress()}\n'
                                  '예약이 완료되었습니다.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black),
                            )),
                      );
                    }
                    else {
                      setState(() {
                        button_pressed = false;
                      });
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ) : Container(),
          willDisplayWidget: Center(
              child: Text(
                '${fp.getUserInfo()['name']}님\n'
                    '${DateFormat('yyyy년 MM월 dd일').format(
                    _reservation_time)}, ${time_zone}\n'
                    '${reservationInfo.getAddress()} ${reservationInfo
                    .getDetailedAddress()}\n'
                    '쓰레기 수거 예약 하시겠습니까?',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
        );
      }
      else {
        return await PopupBox.showPopupBox(
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
                  '주소 또는 예약 시간을 확인해주세요.',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                )));
      }
    }
    else {
      return await PopupBox.showPopupBox(
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
  }

  Future<Widget> reservationBtn_deliver() async {
    _now = await NTP.now();
    reservationInfo.setCustomerRequests(customerRequestCont.text.trim());
    setRememberRequests(reservationInfo.getCustomerRequests());
    reservationInfo.setApplicationTime(_now);
    if (fp.getUserInfo()['phone'] == '0') {
      return await PopupBox.showPopupBox(
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
                '마이페이지에서 휴대폰 인증을 해주시기 바랍니다.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )));
    }
    else if (reservationInfo
        .getAddress()
        .length > 0 && reservationInfo.getReservationTime().difference(_now) >
        Duration(minutes: 59)) {
      return await PopupBox.showPopupBox(
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
                logger.d(button_pressed);
                if (!button_pressed) {
                  setState(() {
                    button_pressed = true;
                  });
                  reservationInfo.setName(fp.getUserInfo()['name']);
                  bool reservation_result = await reservationInfo
                      .saveReservationInfo("deliver", context);
                  logger.d('why?');
                  if (reservation_result) {
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
                    fp.setUserInfo_notify();
                    Navigator.pop(context);
                  }
                  print('예약 완료');
                  setState(() {
                    button_pressed = false;
                  });
                  return await PopupBox.showPopupBox(
                      context: context,
                      button: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      willDisplayWidget: new Center(
                          child: Text(
                            '${fp
                                .getUser()
                                .displayName}님\n${DateFormat('yyyy년 MM월 dd일')
                                .format(
                                _reservation_time)}, ${time_zone}\n 쓰레기통 배송 예약이 완료되었습니다.',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )));
                }
                else {
                  setState(() {
                    button_pressed = false;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        willDisplayWidget: Center(
            child: Text(
              '${fp.getUserInfo()['name']}님\n'
                  '${DateFormat('yyyy년 MM월 dd일').format(
                  _reservation_time)}, ${time_zone}\n'
                  '${reservationInfo.getAddress()} ${reservationInfo
                  .getDetailedAddress()}\n'
                  '쓰레기통 배송 예약 하시겠습니까?',
              style: TextStyle(fontSize: 16, color: Colors.black),
            )),
      );
    }
    else {
      return await PopupBox.showPopupBox(
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
                '주소 또는 예약 시간을 확인해주세요.',
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
