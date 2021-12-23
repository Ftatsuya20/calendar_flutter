import 'package:chutoreal/calender.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:chutoreal/SecondScreen.dart';
import 'package:chutoreal/gacha.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter table calendar',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CalendarScreen(),
        '/list': (context) => SecondScreen(),
        '/gacha': (context) => gachapage(),
      },
      // home: CalendarScreen(),
    );
  }
}
