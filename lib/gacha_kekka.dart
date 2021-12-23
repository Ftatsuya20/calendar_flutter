import 'package:flutter/material.dart';
import 'dart:math';

class gachakekkaPage extends StatefulWidget {
  @override
  _gachakekkaPageState createState() => _gachakekkaPageState();
}

class _gachakekkaPageState extends State<gachakekkaPage> {
  List<String> money = ["100", "100", "100", "100", "200", "200", "500"];

  int num = Random().nextInt(7);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ガチャ結果'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(money[0] + '円が当たりました',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.all(30),
            child: Container(color: Colors.white),
          ),
          Text('引き換えコード', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('s7898wjdn389ujps')
        ]),
      ),
    );
  }
}
