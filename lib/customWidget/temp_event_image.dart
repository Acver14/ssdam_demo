import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// App widget class
class eventPage extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'IntroViews Flutter', //title of app
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ), //ThemeData
        home: Image.asset('assets/event/event_page_0.png',
            fit: BoxFit.contain)); //Material App
  }
}
