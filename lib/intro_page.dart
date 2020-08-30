import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ssdam_demo/auth/signin_page.dart';
import 'package:ssdam_demo/style/customColor.dart';

/// App widget class
class IntroPage extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
      pageColor: const Color(0xFF696F73),
      body: Text(
        '문앞에 놓는게 부담되지않도록 냄새 안나게 할거임 밀봉 킹임',
      ),
      title: Text('쓰담'),
      mainImage: Image.asset(
        'assets/cat.jpg',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    PageViewModel(
      pageColor: const Color(0xFF9CB6CF),
      body: Text(
        '조사해보니깐 3명중에 1명은 필요로 하더라고\n우리가 그 귀찮음을 처리해드림',
      ),
      title: Text('쓰담'),
      mainImage: Image.asset(
        'assets/trash-can.jpg',
        height: 285.0,
        width: 285.0,
        alignment: Alignment.center,
      ),
      titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    PageViewModel(
        pageColor: COLOR_SSDAM,
        bubble: Image.asset(''),
        title: Text(
          '쓰담',
        ),
        body: Text(
          '쓰레기를 담다\n지금 시작해보세요',
        ),
        titleTextStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white),
        mainImage: Image.asset(
          'assets/ssdam_logo.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        )),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IntroViews Flutter', //title of app
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), //ThemeData
      home: Builder(
        builder: (context) => IntroViewsFlutter(
          pages,
          showNextButton: false,
          showBackButton: false,
          onTapDoneButton: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInPage(),
              ), //MaterialPageRoute
            );
          },
          pageButtonTextStyles: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ), //IntroViewsFlutter
      ), //Builder
    ); //Material App
  }
}
