import 'package:flutter/material.dart';
import 'package:chutoreal/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

import 'calender.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  DateTime date = DateTime.now();
  double text = 0;

  final TextStyle style1 = TextStyle(fontSize: 30.0, color: Colors.black);
  final TextStyle style2 = TextStyle(fontSize: 30.0, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    DateFormat out = DateFormat('yyyy-MM-dd');
    String henka = this.date.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('データ入力'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '今日したこと',
                style: style2,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(color: Colors.white),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'メモ',
              ),
              controller: nameController,
              style: style1,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '体重',
                style: style2,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(color: Colors.white),
            ),
            TextField(
              onChanged: (String value) {
                text = double.parse(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '数値を入力',
              ),
              controller: weightController,
              style: style1,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(color: Colors.white),
            ),
            Text((DateFormat('yyyy年MM月dd日')).format(this.date),
                style: TextStyle(fontSize: 32)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF5CC31),
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('選択'),
              onPressed: () => this.selectDate(context),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Container(color: Colors.white),
            ),
            ElevatedButton(
                child: const Text('保存する'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF61D58),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (text != 0) {
                    _saveData();
                    final newListText = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        // 遷移先の画面としてリスト追加画面を指定
                        return CalendarScreen();
                      }),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  selectDate(BuildContext context) async {
    // 1年前から1年後の範囲でカレンダーから日付を選択します。
    var selectedDate = await showDatePicker(
      context: context,
      initialDate: this.date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    // 選択がキャンセルされた場合はNULL
    if (selectedDate == null) return;

    // 選択されて日付で更新
    this.setState(() {
      this.date = selectedDate;
    });
  }

  /// データを保存する
  void _saveData() async {
    /// データベースのパスを取得
    String dbFilePath = await getDatabasesPath();
    String path = join(dbFilePath, Constants().dbName);

    /// 保存するデータの用意
    String memoi = nameController.text;
    String weight = weightController.text;
    DateTime? datet = this.date;

    /// SQL文
    String query =
        'INSERT INTO ${Constants().tableName}(memo, weight, date) VALUES("$memoi", "$weight", "$datet")';

    Database db = await openDatabase(path, version: Constants().dbVersion,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, memo TEXT, weight TEXT), date TEXT");
    });

    /// SQL 実行
    await db.transaction((txn) async {
      int id = await txn.rawInsert(query);
      print("保存成功 id: $id");
    });

    /// ウィジェットの更新
    setState(() {
      nameController.text = "";
      weightController.text = "";
      this.date = DateTime.now();
    });
  }
}
