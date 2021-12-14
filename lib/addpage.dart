import 'package:flutter/material.dart';
import 'package:chutoreal/constants.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime date = DateTime.now();

  final TextStyle style1 = TextStyle(
      fontSize: 30.0,
      color: Colors.black
  );
  final TextStyle style2 = TextStyle(
      fontSize: 30.0,
      color: Colors.black
  );


  @override
  Widget build(BuildContext context) {
    DateFormat out = DateFormat('yyyy-MM-dd');
    String henka = this.date.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Input'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('体調:', style: style2,),
            ),
            TextField(
              controller: nameController,
              style: style1,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('体重', style: style2,),
            ),
            TextField(
              controller: emailController,
              style: style1,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('体温', style: style2,),
            ),
            TextField(
              controller: phoneController,
              style: style1,
            ),
            Text(this.date.toString(), style: TextStyle(fontSize: 32)),
            ElevatedButton(
              child: Text('選択'),
              onPressed: () => this.selectDate(context),
            ),
          ],
        ),
      ),
    /*  bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text('追加'),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
              title: Text('一覧'),
              icon: Icon(Icons.list)
          ),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/list');
          }
        },
      ),*/
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          _saveData();
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("保存しました"),
                content: Text('データベースに保存できました'),
              )
          );
        },
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
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    DateTime? datet = this.date;
    /// SQL文
    String query = 'INSERT INTO ${Constants().tableName}(name, mail, tel, date) VALUES("$name", "$email", "$phone", "$datet")';

    Database db = await openDatabase(path, version: Constants().dbVersion, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, mail TEXT, tel TEXT), date TEXT"
      );
    });

    /// SQL 実行
    await db.transaction((txn) async {
      int id = await txn.rawInsert(query);
      print("保存成功 id: $id");
    });

    /// ウィジェットの更新
    setState(() {
      nameController.text = "";
      emailController.text = "";
      phoneController.text = "";
      this.date = DateTime.now();
    });
  }
}