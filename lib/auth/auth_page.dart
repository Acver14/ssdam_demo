import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/intro_page.dart';
import 'package:ssdam_demo/signedin_page.dart';
import 'package:provider/provider.dart';


AuthPageState pageState;


class AuthPage extends StatefulWidget {
  @override
  AuthPageState createState() {
    pageState = AuthPageState();
    return pageState;
  }
}

class AuthPageState extends State<AuthPage> {
  FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    //logger.d("user: ${fp.getUser()}");
    //logger.d("user: ${fp.getUser().email}");
    if (fp.getUser() != null && fp.getUser().isEmailVerified == true) {
      return SignedInPage();
    } else {
      return IntroPage();
    }
  }
}
