import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:popup_box/popup_box.dart';

EnrollEmailPageState pageState;

class EnrollEmailPage extends StatefulWidget {
  @override
  EnrollEmailPageState createState() {
    pageState = EnrollEmailPageState();
    return pageState;
  }
}

class EnrollEmailPageState extends State<EnrollEmailPage> {
  TextEditingController _mailCon = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider fp;

  @override
  void dispose() {
    _mailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (fp == null) {
      fp = Provider.of<FirebaseProvider>(context);
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("Sign-Up Page")),
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
                    height: 300.0,
                  ),
                  // Input Area
                  Container(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _mailCon,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            hintText: "Email",
                          ),
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

            // Sign Up Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  _signUp();
                },
              ),
            ),
          ],
        ));
  }

  void _signUp() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("인증 메일 전송 중입니다 ... ")
          ],
        ),
      ));
    bool result = true; //await fp.enroll_email(_mailCon.text.trim());
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result) {
      // await PopupBox.showPopupBox(
      //     context: context,
      //     button: MaterialButton(
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(20),
      //       ),
      //     ),
      //     willDisplayWidget: Column(
      //       children: <Widget>[
      //         Text(
      //           '등록하신 이메일로 인증 확인부탁드리겠습니다.',
      //           style: TextStyle(fontSize: 16, color: Colors.black),
      //         ),
      //       ],
      //     ));
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: Colors.black12,
          duration: Duration(seconds: 10),
          content: Text('등록하신 이메일로 인증 확인부탁드리겠습니다.'),
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ));
      Navigator.pop(context);
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
}
