import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'customWidget/loading_widget.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:async/async.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share/share.dart';
import 'package:ntp/ntp.dart';
import 'package:popup_box/popup_box.dart';
import 'package:http/http.dart' as http;
import 'customClass/otp.dart';

MyPageState pageState;

class MyPage extends StatefulWidget {
  @override
  MyPageState createState() {
    pageState = MyPageState();
    return pageState;
  }
}

class MyPageState extends State<MyPage> {
  FirebaseProvider fp;
  var grid_height, grid_width;
  QuerySnapshot reservation_infos;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _now;
  bool _load = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _load = false;
  }

  Future<Map<String, dynamic>> Loading() async {
    //Map<String, dynamic> _user_info = null;
    if (!_load) {
      await fp.setUserInfo();
      _load = true;
    }
    //_user_info = fp.getUserInfo();

    _now = await NTP.now();
    reservation_infos = await Firestore.instance
        .collection('reservationList')
        .document(fp.getUser().uid)
        .collection('reservationInfo')
        .getDocuments();
    return fp.getUserInfo();
  }

  @override
  Widget build(BuildContext context){
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        //extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarOpacity: 1.0,
          title: Text('마이페이지', style: TextStyle(color: Colors.black)),
        ),
        drawer: sideDrawer(context, fp),
        body: FutureBuilder(
            future: Loading(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              //logger.d(snapshot.data);
              if (snapshot.hasData && !snapshot.data.isEmpty) {
                return widgetUserInfo();
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
            })
    );
  }

  Widget widgetUserInfo(){
    grid_height = getDisplayHeight(context) / 10;
    grid_width = getDisplayWidth(context) / 10;
    return ListView(
      children: <Widget>[
        Card(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Container(
                  child: Image.asset("assets/user_default_image.png"),
                  width: grid_height / 2,
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                InkWell(
                  child: Text('이름 : ${fp.getUserInfo()['name']}'),
                  onTap: () async {
                    TextEditingController _nameCon =
                        new TextEditingController();
                    await PopupBox.showPopupBox(
                        context: context,
                        button: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: COLOR_SSDAM,
                          child: Text(
                            'Ok',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () async {
                            await Firestore.instance
                                .collection('userInfo')
                                .document(fp.getUser().uid)
                                .setData({'name': _nameCon.text.trim()},
                                    merge: true);
                            await fp.setUserInfo();
                            Navigator.of(context).pop();
                          },
                        ),
                        willDisplayWidget: Column(
                          children: <Widget>[
                            Text(
                              '이름을 입력해주세요',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            TextField(
                              controller: _nameCon,
                            )
                          ],
                        ));
                  },
                ),
                Text('이메일 : ${fp.getUserInfo()['email']}'),
                InkWell(
                  child: Text(
                      '휴대폰 : ${fp.getUserInfo()['phone'] == '0' ? '번호를 인증하셔야합니다.' : fp.getUserInfo()['phone']}'),
                  onTap: () async {
                    TextEditingController _phoneCon =
                        new TextEditingController();
                    TextEditingController _otpCon = new TextEditingController();
                    FlutterOtp _otp = new FlutterOtp();
                    if (fp.getUserInfo()['phone'] == '0') {
                      var user_list = await Firestore.instance
                          .collection('uidSet')
                          .getDocuments();
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          willDisplayWidget: Center(
                              child: Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: _phoneCon,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.phone),
                                    hintText: "Phone(01012345678)",
                                  ),
                                ),
                              ),
                              FlatButton(
                                  child: Text(
                                    '전송',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () async {
                                    var phone_check = false;
                                    user_list.documents.forEach((element) {
                                      logger.d(element.data['phone']);
                                      if (_phoneCon.text.trim() ==
                                          element.data['phone']) {
                                        phone_check = true;
                                        return;
                                      }
                                    });
                                    if (phone_check) {
                                      await PopupBox.showPopupBox(
                                          context: context,
                                          button: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          willDisplayWidget: Column(
                                            children: <Widget>[
                                              Text(
                                                '중복된 번호입니다.',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ));
                                    } else {
                                      await _otp.sendOtp(_phoneCon.text.trim(),
                                          null, 1000, 9999, '+82');
                                      await PopupBox.showPopupBox(
                                          context: context,
                                          button: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          willDisplayWidget: Column(
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: TextField(
                                                      controller: _otpCon,
                                                      decoration:
                                                          InputDecoration(
                                                        prefixIcon:
                                                            Icon(Icons.chat),
                                                        hintText: "1234",
                                                      ),
                                                    ),
                                                  ),
                                                  FlatButton(
                                                      child: Text(
                                                        '확인',
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      onPressed: () async {
                                                        var result = _otp
                                                            .resultChecker(int
                                                                .parse(_otpCon
                                                                    .text
                                                                    .trim()));
                                                        if (result) {
                                                          Firestore.instance
                                                              .collection(
                                                                  'userInfo')
                                                              .document(fp
                                                                  .getUser()
                                                                  .uid)
                                                              .setData({
                                                            'phone': _phoneCon
                                                                .text
                                                                .trim()
                                                          }, merge: true);
                                                          Firestore.instance
                                                              .collection(
                                                                  'uidSet')
                                                              .document(
                                                                  fp.getUserInfo()[
                                                                      'email'])
                                                              .setData({
                                                            'phone': _phoneCon
                                                                .text
                                                                .trim()
                                                          }, merge: true);
                                                          await fp
                                                              .setUserInfo_notify();
                                                          await PopupBox
                                                              .showPopupBox(
                                                                  context:
                                                                      context,
                                                                  button:
                                                                      MaterialButton(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                  ),
                                                                  willDisplayWidget:
                                                                      Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        '인증이 완료되었습니다.',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ],
                                                                  ));
                                                          Navigator.of(context)
                                                              .pop();
                                                        } else {
                                                          await PopupBox
                                                              .showPopupBox(
                                                                  context:
                                                                      context,
                                                                  button:
                                                                      MaterialButton(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                  ),
                                                                  willDisplayWidget:
                                                                      Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        '잘못된 인증번호입니다. 재전송합니다.',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                    ],
                                                                  ));
                                                          await _otp.sendOtp(
                                                              _phoneCon.text
                                                                  .trim(),
                                                              null,
                                                              0000,
                                                              9999,
                                                              '+82');
                                                        }
                                                      })
                                                ],
                                              ),
                                            ],
                                          ));
                                      Navigator.of(context).pop();
                                    }
                                  })
                            ],
                          )));
                    }
                  },
                ),
                //마케팅 수집 동의 변경 부 (수정 필요)
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: fp.getUserInfo()['marketing'],
                      onChanged: (newValue) async {
                        await Firestore.instance
                            .collection('userInfo')
                            .document(fp.getUser().uid)
                            .setData({'marketing': newValue}, merge: true);
                        await fp.setUserInfo_notify();
                        setState() {}
                        ;
                      },
                    ),
                    Text("마케팅 수신 동의"),
                  ],
                ),
                  ],
                )
              ],
            )
        ),
        Row(
          children: [
            Container(
              width: grid_width * 5,
              child: Card(
                  child:ListTile(
                    title: Text(
                        '이용권'
                    ),
                    subtitle: Text('${fp.getUserInfo()['tickets']}'),
                  )
              ),
            ),
            Container(
                width: grid_width * 5,
                child: Card(
                    child: ListTile(
                      title: Text(
                          '포인트'
                      ),
                      subtitle: Text('${fp.getUserInfo()['points'] +
                          fp.getUserInfo()['promotion_points']}'),
                    )
                )
            )
          ],
        ),
        Container(
          child: Card(
            child: ListTile(
                title: Text(
                    '추천인 코드'
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        FlutterClipboard.copy(
                            fp.getUserInfo()['promotionCode']);
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: Duration(seconds: 2),
                            content: Row(
                              children: <Widget>[
                                Text("복사되었습니다.")
                              ],
                            ),
                          ));
                      },
                      child: Text('${fp.getUserInfo()['promotionCode']}'),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: IconButton(
                            icon: new Icon(Icons.content_copy),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              FlutterClipboard.copy(
                                  fp.getUserInfo()['promotionCode']);
                              _scaffoldKey.currentState
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  duration: Duration(seconds: 2),
                                  content: Row(
                                    children: <Widget>[
                                      Text("복사되었습니다.")
                                    ],
                                  ),
                                ));
                            },
                          ),
                        ),
                        SizedBox(
                            width: 30,
                            child: IconButton(
                              icon: new Icon(Icons.share),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                final RenderBox box = context
                                    .findRenderObject();
                                Share.share(
                                    '- 안드로이드 : https://bit.ly/2HD1n7P\n- ios : https://apple.co/3oPluAq',
                                    subject: '친구와 함께 쓰담을 이용하세요! - 친구 추천 코드 입력 후, 쓰담 이용시 무료 이용권을 받게 됩니다.\n추천코드 :\n${fp
                                        .getUserInfo()['promotionCode']}\n\n',
                                    sharePositionOrigin: box.localToGlobal(
                                        Offset.zero) & box.size);
                              },
                            )
                        )
                      ],
                    )
                  ],
                )
            ),

          ),
        ),
        serviceState(),
        reservationInfoChart(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            child: RaisedButton(
              child: Text('회원 탈퇴'),
              onPressed: () async {
                PopupBox.showPopupBox(
                  context: context,
                  button: Row(
                    children: [
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: COLOR_SSDAM,
                        child: Text(
                          '취소',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 10),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: COLOR_SSDAM,
                        child: Text(
                          '확인',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () async {
                          fp.getUser().delete();
                          await PopupBox.showPopupBox(
                            context: context,
                            button: MaterialButton(
                              onPressed: () {
                                fp.setUserInfo_notify();
                                Navigator.pop(context);
                              },
                            ),
                            willDisplayWidget: Center(
                                child: Text(
                                  '${fp
                                      .getUserInfo()['name']}님\n회원 탈퇴가 완료되었습니다.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                )),
                          );
                          logger.d('회원 정보 삭제 성공');
                          fp.setUser(null);
                          SystemNavigator.pop();
                          return;
                        },
                      ),
                    ],
                  ),
                  willDisplayWidget: Center(
                      child: Text(
                        '${fp.getUserInfo()['name']}님 회원 탈퇴하시겠습니까?',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  Widget serviceState(){
    var service;

    if (fp.getUserInfo()['service'] == null ||
        fp.getUserInfo()['service'] == '') {
      return Card(
          child: ListTile(
            title: Text('이용 중인 서비스가 없습니다.'),
          ));
    } else {
      switch (fp.getUserInfo()['service']) {
        case 'periodic20000':
          service = "정기권 20000원";
          break;
        case 'periodic30000':
          service = "정기권 30000원";
          break;
        case 'periodic40000':
          service = "정기권 40000원";
          break;
      }
      return Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '이용 중인 서비스 : $service'),
                new IconButton(
                  icon: new Icon(Icons.cancel),
                  onPressed: () async {
                    PopupBox.showPopupBox(
                      context: context,
                      button: Row(
                        children: [
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: COLOR_SSDAM,
                            child: Text(
                              '취소',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 10),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: COLOR_SSDAM,
                            child: Text(
                              '확인',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () async {
                              final token_response = await http.post(
                                  'https://api.iamport.kr/users/getToken',
                                  body: <String, String>{
                                    "imp_key": "3956099518425955",
                                    "imp_secret": "L2oczMLUMjAQivqpoRCTQ9pyrazmwV7iYvuxigs5z2VSymhWdUQ33gCvrbRY7Yg6tLEM26RC9NuH9MEm"
                                  });

                              var token = json.decode(token_response
                                  .body)['response']['access_token'];

                              logger.d(json.decode(token_response.body));
                              logger.d(token);
                              final response = await http.post(
                                  'https://api.iamport.kr/subscribe/payments/unschedule',
                                  headers: <String, String>{
                                    'Authorization': token
                                  },
                                  body: <String, String>{
                                    'customer_uid': fp.getUserInfo()['email'] +
                                        '_' + fp.getUserInfo()['service']
                                  });
                              logger.d(json.decode(response.body));
                              if (response.statusCode == 200) {
                                await Firestore.instance.collection('userInfo')
                                    .document(fp
                                    .getUser()
                                    .uid)
                                    .setData(
                                    {
                                      'service': null,
                                      'publish_date': null
                                    }, merge: true
                                );
                                fp.setUserInfo_notify();
                                print('정기 결제 취소 성공');
                                Navigator.of(context).pop();
                                return await PopupBox.showPopupBox(
                                  context: context,
                                  button: MaterialButton(
                                    onPressed: () {
                                      fp.setUserInfo_notify();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  willDisplayWidget: Center(
                                      child: Text(
                                        '${fp
                                            .getUserInfo()['name']}님\n정기 결체 취소가 완료되었습니다.',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )),
                                );
                              }
                              else {
                                Navigator.of(context).pop();
                                return await PopupBox.showPopupBox(
                                  context: context,
                                  button: MaterialButton(
                                    onPressed: () {
                                      fp.setUserInfo_notify();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  willDisplayWidget: Center(
                                      child: Text(
                                        '${fp
                                            .getUserInfo()['name']}님\n정기 결체 취소가 실패하였습니다\n증상이 반복될 시 문의 부탁드립니다.',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      willDisplayWidget: Center(
                          child: Text(
                            '${fp.getUserInfo()['name']}님 정기 결제를 취소하시겠습니까?',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )),
                    );
                  },)
              ],
            ),
            subtitle: fp.getUserInfo() == null ? Text('') : Text(
                '결제일 : 매월 ${DateTime
                    .fromMillisecondsSinceEpoch(
                    fp.getUserInfo()['publish_date'])
                    .day}일'
            ),
          )
      );
    }
  }

  Widget reservationInfoChart() {
    final fromDate = _now.subtract(Duration(days: 180));
    final toDate = _now;

    final date1 = _now.subtract(Duration(days: 1));
    final date2 = _now.subtract(Duration(days: 30));

    final date3 = _now.subtract(Duration(days: 60));
    final date4 = _now.subtract(Duration(days: 90));

    final date5 = _now.subtract(Duration(days: 120));
    final date6 = _now.subtract(Duration(days: 150));

    var value1 = 0.0;
    var value2 = 0.0;
    var value3 = 0.0;
    var value4 = 0.0;
    var value5 = 0.0;
    var value6 = 0.0;
    // print(fromDate);
    // print(toDate);
    List<DocumentSnapshot> reservation_info = reservation_infos.documents;
    reservation_info.forEach((element) {
      DateTime temp;
      if (element.data['state'] == 'complete' ||
          element.data['state'] == 'register') {
        temp = Timestamp.fromMillisecondsSinceEpoch(
            int.parse(element.documentID.split('=')[1].split(',')[0]) *
                1000)
            .toDate();
        // print('temp : $temp');
        // print(int.parse(element.documentID.split('=')[1].split(',')[0]));
        // print('in days: ${DateTime.now().difference(temp).inDays}');
        if (_now
            .difference(temp)
            .inDays < 151) {
          switch ((_now
              .difference(temp)
              .inDays ~/ 30)) {
            case 5:
              value6 += 1.0;
              break;
            case 4:
              value5 += 1.0;
              break;
            case 3:
              value4 += 1.0;
              break;
            case 2:
              value3 += 1.0;
              break;
            case 1:
              value2 += 1.0;
              break;
            case 0:
              value1 += 1.0;
              break;
          }
        }
      }
      //DateTime temp = DateTime.fromMicrosecondsSinceEpoch(element.data['reservationTime']);
    });

    // print("1: ${value1}, 2: ${value2}, 3 : ${value3}, 4 : ${value4}, 5 : ${value5}, 6 : ${value6}");
    return Card(
        child:ListTile(
          title: Text('최근 6개월 이용 내역'),
          subtitle: Center(
            child: Container(
              color: Colors.white,
              height: grid_height * 4,
              width: grid_width * 10,
              child: BezierChart(
                bezierChartScale: BezierChartScale.MONTHLY,
                fromDate: fromDate,
                toDate: toDate,
                selectedDate: toDate,
                series: [
                  BezierLine(
                    label: "회 예약",
                    lineColor: COLOR_SSDAM,
                    lineStrokeWidth: 2.0,
                    onMissingValue: (dateTime) {
                      return 0.0;
                    },
                    data: [
                      DataPoint<DateTime>(value: value1, xAxis: date1),
                      DataPoint<DateTime>(value: value2, xAxis: date2),
                      DataPoint<DateTime>(value: value3, xAxis: date3),
                      DataPoint<DateTime>(value: value4, xAxis: date4),
                      DataPoint<DateTime>(value: value5, xAxis: date5),
                      DataPoint<DateTime>(value: value6, xAxis: date6),
                    ],
                  ),
                ],

                config: BezierChartConfig(
                  displayLinesXAxis: true,
                  verticalIndicatorStrokeWidth: 10.0,
                  verticalIndicatorColor: Colors.black26,
                  showVerticalIndicator: true,
                  verticalIndicatorFixedPosition: false,
                  backgroundColor: Colors.white60,
                  footerHeight: grid_height,
                  xAxisTextStyle: TextStyle(color: Colors.black),
                  yAxisTextStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        )
    );
  }
}

showGuidance(String text, GlobalKey<ScaffoldState> _scaffoldKey) {
  _scaffoldKey.currentState
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      duration: Duration(seconds: 10),
      content: Text(text),
      action: SnackBarAction(
        label: "Done",
        textColor: Colors.white,
        onPressed: () {},
      ),
    ));
}