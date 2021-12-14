import 'package:chutoreal/calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:chutoreal/addpage.dart';
import 'package:chutoreal/SecondScreen.dart';


void main() {
  initializeDateFormatting().then((_) =>runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter table calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      /*initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(),
        '/list': (context) => SecondScreen(),
      },*/
      home: CalendarScreen(),
    );
  }
}