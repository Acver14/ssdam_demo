import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:ssdam_demo/auth/signin_page.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

/// App widget class
class IntroPage extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
      pageColor: const Color(0xFF696F73),
      body: Text(
        '',
      ),
      title: Text('쓰담'),
      mainImage: Image.asset(
        'assets/intro_view/intro_1.png',
        fit: BoxFit.fitWidth,
        alignment: Alignment.center,
      ),
      titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
    ),
    PageViewModel(
      pageColor: const Color(0xFF9CB6CF),
      body: Text(''),
      title: Text('쓰담'),
      mainImage: Image.asset(
        'assets/intro_view/intro_2.jpg',
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
//
// class IntroScreen extends StatefulWidget {
//   IntroScreen({Key key}) : super(key: key);
//
//   @override
//   IntroScreenState createState() => new IntroScreenState();
// }
//
// class IntroScreenState extends State<IntroScreen> {
//   List<Slide> slides = new List();
//
//   Function goToTab;
//
//   @override
//   void initState() {
//     super.initState();
//
//     slides.add(
//       new Slide(
//         title: "쓰담",
//         styleTitle: TextStyle(
//             color: Color(0xff3da4ab),
//             fontSize: 30.0,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'RobotoMono'),
//         description: "hihiadfjsdopfjsaopfjdp",
//         styleDescription: TextStyle(
//             color: Color(0xfffe9c8f),
//             fontSize: 20.0,
//             fontStyle: FontStyle.italic,
//             fontFamily: 'Raleway'),
//         pathImage: "assets/intro_view/intro_1.png",
//       ),
//     );
//     slides.add(
//       new Slide(
//         title: "쓰담",
//         //widthImage: double.infinity,
//         styleTitle: TextStyle(
//             color: Color(0xff3da4ab),
//             fontSize: 30.0,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'RobotoMono'),
//         description:
//         "",
//         styleDescription: TextStyle(
//             color: Color(0xfffe9c8f),
//             fontSize: 20.0,
//             fontStyle: FontStyle.italic,
//             fontFamily: 'Raleway'),
//         pathImage: "assets/intro_view/intro_2.jpg",
//       ),
//     );
//     slides.add(
//       new Slide(
//         title: "COFFEE SHOP",
//         styleTitle: TextStyle(
//             color: Color(0xff3da4ab),
//             fontSize: 30.0,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'RobotoMono'),
//         description:
//         "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
//         styleDescription: TextStyle(
//             color: Color(0xfffe9c8f),
//             fontSize: 20.0,
//             fontStyle: FontStyle.italic,
//             fontFamily: 'Raleway'),
//         pathImage: "images/photo_coffee_shop.png",
//       ),
//     );
//   }
//
//   void onDonePress() {
//     // Back to the first tab
//     this.goToTab(0);
//   }
//
//   void onTabChangeCompleted(index) {
//     // Index of current tab is focused
//   }
//
//   Widget renderNextBtn() {
//     return Icon(
//       Icons.navigate_next,
//       color: Color(0xffffcc5c),
//       size: 35.0,
//     );
//   }
//
//   Widget renderDoneBtn() {
//     return Icon(
//       Icons.done,
//       color: Color(0xffffcc5c),
//     );
//   }
//
//   Widget renderSkipBtn() {
//     return Icon(
//       Icons.skip_next,
//       color: Color(0xffffcc5c),
//     );
//   }
//
//   List<Widget> renderListCustomTabs() {
//     List<Widget> tabs = new List();
//     for (int i = 0; i < slides.length; i++) {
//       Slide currentSlide = slides[i];
//       tabs.add(Container(
//         width: double.infinity,
//         height: double.infinity,
//         child: Container(
//           margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
//           child: ListView(
//             children: <Widget>[
//               GestureDetector(
//                   child: Image.asset(
//                     currentSlide.pathImage,
//                     width: 200.0,
//                     height: 200.0,
//                     fit: BoxFit.contain,
//                   )),
//               Container(
//                 child: Text(
//                   currentSlide.title,
//                   style: currentSlide.styleTitle,
//                   textAlign: TextAlign.center,
//                 ),
//                 margin: EdgeInsets.only(top: 20.0),
//               ),
//               Container(
//                 child: Text(
//                   currentSlide.description,
//                   style: currentSlide.styleDescription,
//                   textAlign: TextAlign.center,
//                   maxLines: 5,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 margin: EdgeInsets.only(top: 20.0),
//               ),
//             ],
//           ),
//         ),
//       ));
//     }
//     return tabs;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new IntroSlider(
//       // List slides
//       slides: this.slides,
//
//       // Skip button
//       renderSkipBtn: this.renderSkipBtn(),
//       colorSkipBtn: Color(0x33ffcc5c),
//       highlightColorSkipBtn: Color(0xffffcc5c),
//
//       // Next button
//       renderNextBtn: this.renderNextBtn(),
//
//       // Done button
//       renderDoneBtn: this.renderDoneBtn(),
//       onDonePress: this.onDonePress,
//       colorDoneBtn: Color(0x33ffcc5c),
//       highlightColorDoneBtn: Color(0xffffcc5c),
//
//       // Dot indicator
//       colorDot: Color(0xffffcc5c),
//       sizeDot: 13.0,
//       typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
//
//       // Tabs
//       listCustomTabs: this.renderListCustomTabs(),
//       backgroundColorAllSlides: Colors.white,
//       refFuncGoToTab: (refFunc) {
//         this.goToTab = refFunc;
//       },
//
//       // Show or hide status bar
//       shouldHideStatusBar: true,
//
//       // On tab change completed
//       onTabChangeCompleted: this.onTabChangeCompleted,
//     );
//   }
// }
