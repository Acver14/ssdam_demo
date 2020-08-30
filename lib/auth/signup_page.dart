import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

SignUpPageState pageState;

class SignUpPage extends StatefulWidget {
  @override
  SignUpPageState createState() {
    pageState = SignUpPageState();
    return pageState;
  }
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController _mailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  TextEditingController _nameCon = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider fp;

  @override
  void dispose() {
    _mailCon.dispose();
    _pwCon.dispose();
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
                          controller: _nameCon,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_box),
                            hintText: "Name",
                          ),
                        ),
                        TextField(
                          controller: _mailCon,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            hintText: "Email",
                          ),
                        ),
                        TextField(
                          controller: _pwCon,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: "Password",
                          ),
                          obscureText: true,
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
            Text("   Signing-Up...")
          ],
        ),
      ));
    bool result = await fp.signUpWithEmail(_mailCon.text.trim(), _pwCon.text.trim(), _nameCon.text.trim());
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result) {
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