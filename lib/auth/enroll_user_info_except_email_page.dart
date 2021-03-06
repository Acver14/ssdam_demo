import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ssdam_demo/customClass/otp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:popup_box/popup_box.dart';

EnrollUserInfo_exceptEmailPageState pageState;

class EnrollUserInfo_exceptEmailPage extends StatefulWidget {
  @override
  EnrollUserInfo_exceptEmailPageState createState() {
    pageState = EnrollUserInfo_exceptEmailPageState();
    return pageState;
  }
}

class EnrollUserInfo_exceptEmailPageState
    extends State<EnrollUserInfo_exceptEmailPage> {
  TextEditingController _phoneCon = TextEditingController();
  TextEditingController _otpCon = TextEditingController();
  TextEditingController _promotionCon = TextEditingController();
  bool _marketingAgreement = false;
  bool _personalInformationAgreement = false;
  bool _send_email = false;
  var otp_send = false;
  var otp_true = false;
  var user_list;
  var promotion_code = false;
  var recommender = null;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider fp;
  FlutterOtp _otp = new FlutterOtp();

  userListSetting() async {
    user_list = await Firestore.instance.collection('uidSet').getDocuments();
  }

  @override
  void dispose() {
    _phoneCon.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userListSetting();
  }

  @override
  Widget build(BuildContext context) {
    if (fp == null) {
      fp = Provider.of<FirebaseProvider>(context);
    }

    return WillPopScope(
        //onWillPop: requestPop,
        child: new Scaffold(
            key: _scaffoldKey,
            body: ListView(
              children: <Widget>[
                Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: new AssetImage('assets/ssdam_logo.png'),
                    fit: BoxFit.fitWidth,
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    alignment: Alignment.topCenter,
                  )),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 150.0,
                      ),
                      // Input Area
                      Container(
                        child: Column(
                          children: <Widget>[
                            !otp_true
                                ? Row(
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
                                            user_list.documents
                                                .forEach((element) {
                                              //logger.d(element.data['phone']);
                                              if (_phoneCon.text.trim() ==
                                                  element.data['phone']) {
                                                phone_check = true;
                                                return;
                                              }
                                            });
                                            if (phone_check) {
                                              showGuidance(
                                                  '중복된 번호입니다.', _scaffoldKey);
                                            } else {
                                              await _otp.sendOtp(
                                                  _phoneCon.text.trim(),
                                                  null,
                                                  1000,
                                                  9999,
                                                  '+82');
                                              setState(() {
                                                otp_send = true;
                                              });
                                              logger.d(otp_send);
                                            }
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller: _phoneCon,
                                          enabled: false,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.phone),
                                            hintText: "Phone(01012345678)",
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: new Icon(Icons.check),
                                      )
                                    ],
                                  ),
                            !otp_send
                                ? Container()
                                : Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller: _otpCon,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.chat),
                                            hintText: "1234",
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                          child: Text(
                                            '확인',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          onPressed: () async {
                                            var result = _otp.resultChecker(
                                                int.parse(_otpCon.text.trim()));
                                            if (result) {
                                              otp_true = true;
                                              showGuidance('휴대폰 인증이 완료되었습니다.',
                                                  _scaffoldKey);
                                              setState(() {
                                                otp_send = false;
                                              });
                                            } else {
                                              showGuidance(
                                                  '잘못된 인증 번호입니다. 재전송합니다.',
                                                  _scaffoldKey);
                                              await _otp.sendOtp(
                                                  _phoneCon.text.trim(),
                                                  null,
                                                  0000,
                                                  9999,
                                                  '+82');
                                            }
                                          })
                                    ],
                                  ),
                            !promotion_code
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller: _promotionCon,
                                          decoration: InputDecoration(
                                            prefixIcon:
                                                Icon(Icons.record_voice_over),
                                            hintText: '추천인 코드',
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                          child: Text(
                                            '확인',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          onPressed: () async {
                                            var code_check = false;
                                            user_list.documents
                                                .forEach((element) {
                                              logger.d(element
                                                  .data['promotionCode']);
                                              if (_promotionCon.text.trim() ==
                                                  element
                                                      .data['promotionCode']) {
                                                code_check = true;
                                                recommender =
                                                    element.data['uid'];
                                                return;
                                              }
                                            });
                                            if (code_check) {
                                              showGuidance('추천인이 확인되었습니다..',
                                                  _scaffoldKey);
                                              setState(() {
                                                promotion_code = true;
                                              });
                                            } else {
                                              showGuidance('존재하지 않는 추천인 코드입니다.',
                                                  _scaffoldKey);
                                            }
                                          })
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller: _promotionCon,
                                          enabled: false,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ),
                                          decoration: InputDecoration(
                                            prefixIcon:
                                                Icon(Icons.record_voice_over),
                                            hintText: "Phone(01012345678)",
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: new Icon(Icons.check),
                                      )
                                    ],
                                  ),
                          ].map((c) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: c,
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _personalInformationAgreement,
                        onChanged: (newValue) {
                          setState(() {
                            _personalInformationAgreement = newValue;
                          });
                        },
                      ),
                      Row(
                        children: [
                          Text("개인정보 활용 동의 (필수)"),
                          FlatButton(
                            child: Text(
                              '읽어보기',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => launchWebView(
                                'https://ssdam.net/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.html'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _marketingAgreement,
                        onChanged: (newValue) {
                          setState(() {
                            _marketingAgreement = newValue;
                          });
                        },
                      ),
                      Row(
                        children: [
                          Text("마케팅 수신 동의"),
                        ],
                      )
                    ],
                  ),
                ),
                // Sign Up Button
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: RaisedButton(
                    color: Colors.green[300],
                    child: Text(
                      "회원가입",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context)
                          .requestFocus(new FocusNode()); // 키보드 감춤
                      if (_phoneCon.text.trim() == '') {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: Duration(seconds: 5),
                            content: Row(
                              children: <Widget>[Text("빈칸을 채워주시기 바랍니다.")],
                            ),
                          ));
                      } else if (!_personalInformationAgreement) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: Duration(seconds: 5),
                            content: Row(
                              children: <Widget>[Text("필수 항목 체크해주시기 바랍니다. ")],
                            ),
                          ));
                      } else if (!otp_true) {
                        _scaffoldKey.currentState
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(
                            duration: Duration(seconds: 5),
                            content: Row(
                              children: <Widget>[Text("휴대폰 인증을 해주시기 바랍니다.")],
                            ),
                          ));
                      } else {
                        _signUp();
                      }
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: RaisedButton(
                    color: Colors.redAccent,
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () async {
                      logger.d('delete start');
                      await fp.getUser().delete().then((value) {
                        logger.d('delete complete');
                      }).catchError((onError) {
                        logger.d('error in deleting user, ${onError}');
                      });
                      await fp.signOut();
                      logger.d('delete complete');
                    },
                  ),
                )
              ],
            )));
  }

  void _signUp() async {
    _send_email = true;
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(width: 5),
            Text("회원 가입 진행 중입니다 ... ")
          ],
        ),
      ));
    bool result = await fp.enroll_user_info(
        _phoneCon.text.trim(),
        _marketingAgreement,
        _personalInformationAgreement,
        recommender);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result) {
      _send_email = true;
      await PopupBox.showPopupBox(
          context: context,
          button: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          willDisplayWidget: Column(
            children: <Widget>[
              Text(
                '회원가입이 완료되었습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ));
      await fp.setUserInfo();
      logger.d(fp.getUserInfo()['phone']);
      //Navigator.of(context).maybePop();
    } else {
      showLastFBMessage();
    }
  }

  showLastFBMessage() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red[400],
        duration: Duration(seconds: 10),
        content: Text(fp.getLastFBMessage()),
        action: SnackBarAction(
          label: "Done",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
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

  Future<bool> requestPop() async {
    if (!_send_email) {
      logger.d('delete user info');
      await Firestore.instance
          .collection('userInfo')
          .document(fp.getUser().uid)
          .delete();
      await Firestore.instance
          .collection('fcmTokenInfo')
          .document(fp.getUser().uid)
          .delete();
      fp.getUser().delete();
    }
    return new Future.value(true);
  }

  launchBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'could not launch';
    }
  }

  launchWebView(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'could not launch';
    }
  }
}
