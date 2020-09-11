import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/intro_page.dart';
import 'package:ssdam_demo/signedin_page.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  var _flutter_local_notifications_plugin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    // var iosSetting = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(androidSetting, iosSetting);
    //
    // _flutter_local_notifications_plugin = FlutterLocalNotificationsPlugin();
    // _flutter_local_notifications_plugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    //logger.d("user: ${fp.getUser()}");
    //logger.d("user: ${fp.getUser().email}");
    print(fp.getUser());
    print(fp.getUser() != null);
    if (fp.getUser() != null && fp.getUser().isEmailVerified == true) {
      print('why....!!!!!!!!!!');
      return SignedInPage();
    } else {
      return IntroPage();
    }
  }
}
