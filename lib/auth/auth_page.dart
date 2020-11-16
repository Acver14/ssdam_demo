import 'package:flutter/material.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/intro_page.dart';
import 'package:ssdam_demo/signedin_page.dart';
import 'package:provider/provider.dart';
import 'enroll_user_info.dart';
import 'enroll_user_info_except_email_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/splash_page.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
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

  setDeviceToken() async {
    await Firestore.instance
        .collection('fcmTokenInfo')
        .document(fp.getUser().uid)
        .setData({'token': fp.token});
    logger.d('setDeviceToke: ${fp.getUser().uid}, ${fp.token}');
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    var timer;
    if (fp.getUserInfo() == null) {
      timer = Timer.periodic(new Duration(seconds: 1), (timer) {
        //Logger().d('call user info ${fp.getUserInfo()}');
        fp.setUserInfo_notify();
      });
    }
    //logger.d(fp.getUser());
    //fp.setUserInfo_notify();
    if (fp.getUser() != null) {
      if (fp.getUser().isEmailVerified) {
        if (fp.getUserInfo() == null || fp.getUserInfo().length == 0) {
          return SplashPage();
        } else if (fp.getUserInfo()['phone'] == null) {
          if (fp.getUserInfo() != null && timer != null
              ? timer.isActive
              : false) {
            timer.cancel();
            Logger().d('timer cancel');
          }
          return EnrollUserInfo_exceptEmailPage();
        } else {
          //setDeviceToken();
          if (fp.getUserInfo() != null && timer != null
              ? timer.isActive
              : false) {
            timer.cancel();
            logger.d(timer.isActive);
            //Logger().d('timer cancel');
          }
          return SignedInPage();
        }
      } else {
        if (fp.getUserInfo() == null || fp.getUserInfo().length == 0) {
          return SplashPage();
        } else if (fp.getUserInfo()['phone'] == null) {
          if (fp.getUserInfo() != null && timer != null
              ? timer.isActive
              : false) {
            timer.cancel();
            Logger().d('timer cancel');
          }
          return EnrollUserInfoPage();
        } else
          return IntroPage();
      }
    } else {
      return IntroPage();
    }
  }
}
