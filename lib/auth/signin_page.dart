import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/auth/signup_page.dart';
import 'package:ssdam_demo/authButton/kakao.dart';
import 'package:ssdam_demo/authButton/naver.dart';
import 'package:ssdam_demo/authButton/google.dart';
import 'package:ssdam_demo/style/customColor.dart';
//import 'package:ssdam_demo/auth/kakao_login_page.dart';

SignInPageState pageState;

class SignInPage extends StatefulWidget {
  @override
  SignInPageState createState() {
    pageState = SignInPageState();
    return pageState;
  }
}

class SignInPageState extends State<SignInPage> {
  TextEditingController _mailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  bool doRemember = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseProvider fp;

  @override
  void initState() {
    super.initState();
    getRememberInfo();
  }

  @override
  void dispose() {
    setRememberInfo();
    _mailCon.dispose();
    _pwCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d(fp.getUser());
    return Scaffold(
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
              // Remember Me
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: doRemember,
                      onChanged: (newValue) {
                        setState(() {
                          doRemember = newValue;
                        });
                      },
                    ),
                    Text("로그인 정보 저장")
                  ],
                ),
              ),

              // Alert Box
              (fp.getUser() != null && fp
                  .getUser()
                  .isEmailVerified == false)
                  ? Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: BoxDecoration(color: Colors.red[300]),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "메일 인증이 완료되지 않았씁니다."
                            "\n메일 인증을 완료해주시기 바랍니다.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    RaisedButton(
                      color: Colors.lightBlue[400],
                      textColor: Colors.white,
                      child: Text("인증 메일 재전송"),
                      onPressed: () {
                        FocusScope.of(context)
                            .requestFocus(new FocusNode()); // 키보드 감춤
                        fp.getUser().sendEmailVerification();
                      },
                    )
                  ],
                ),
              )
                  : Container(),

              // Sign In Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: RaisedButton(
                  color: Colors.green[300],
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,),
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode()); // 키보드 감춤
                    _signIn();
                  },
                ),
              ),
              GoogleSignInButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode()); // 키보드 감춤
                  _signInWithGoogle();
                },
              ),
              KakaoSignInButton(
                onPressed: () {}//=> Navigator.push(context, MaterialPageRoute(builder: (context) => KakaoLoginTest())),
              ),
              NaverSignInButton(
                onPressed: () => print('naver'),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "회원가입",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUpPage()));
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
    );
  }

  void _signIn() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("   Signing-In...")
          ],
        ),
      ));
    bool result = await fp.signInWithEmail(
        _mailCon.text.trim(), _pwCon.text.trim());
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == false) showLastFBMessage();
  }

  void _signInWithGoogle() async {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: Duration(seconds: 10),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Text("   Signing-In...")
          ],
        ),
      ));
    bool result = await fp.signInWithGoogleAccount();
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (result == false) showLastFBMessage();
  }

  getRememberInfo() async {
    logger.d(doRemember);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doRemember = (prefs.getBool("doRemember") ?? false);
    });
    if (doRemember) {
      setState(() {
        _mailCon.text = (prefs.getString("userEmail") ?? "");
        _pwCon.text = (prefs.getString("userPasswd") ?? "");
      });
    }
  }

  setRememberInfo() async {
    logger.d(doRemember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("doRemember", doRemember);
    if (doRemember) {
      prefs.setString("userEmail", _mailCon.text);
      prefs.setString("userPasswd", _pwCon.text);
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