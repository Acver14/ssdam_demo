import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/auth/auth_page.dart';
import 'package:ssdam_demo/customClass/reservatioin_info_class.dart';
import 'package:flutter_localizations/flutter_localizations.dart';




void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseProvider>(
            create: (context) => FirebaseProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          // if it's a RTL language
        ],
        supportedLocales: [
          const Locale('ko', 'KR'),
          // include country code too
        ],
        title: "Flutter Firebase",
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      ),
    );
  }
}
