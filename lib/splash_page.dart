import 'package:flutter/material.dart';
import 'customClass/size_constant.dart';
import 'customWidget/loading_widget.dart';
import 'dart:async';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

/// App widget class
class SplashPage extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.

  @override
  Widget build(BuildContext context) {
    FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      body: Container(
        height: getDisplayHeight(context),
        child: widgetLoading(),
      ), //Builder
    ); //Material App
  }
}
