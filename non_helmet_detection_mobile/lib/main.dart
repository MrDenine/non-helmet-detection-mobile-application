// ignore_for_file: empty_catches, unused_catch_clause, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  Intl.defaultLocale = 'th';
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('th', 'TH'), // Thai
        ],
        debugShowCheckedModeBanner: true,
        title: 'None Helmet Detection',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          //fontFamily: 'NotoSansThai'
        ),
        home: SplashPage());
  }
}
