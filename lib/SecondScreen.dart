import 'package:flutter/material.dart';
import 'package:chutoreal/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<Widget> _items = <Widget>[];
  DateTime _dateT = DateTime.now();
  @override
  void initState() {
    super.initState();
    getItems();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('一覧'),
      ),
      body: ListView(
        children: _items,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              title: Text("追加"),
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              title: Text('一覧'),
              icon: Icon(Icons.list)
          )
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// 保存したデータを取り出す
  void getItems() async {
    /// データベースのパスを取得
    DateTime uke = DateTime.now();
    List<Widget> list = <Widget>[];
    String dbFilePath = await getDatabasesPath();
    String path = join (dbFilePath, Constants().dbName);

    /// テーブルがなければ作成する
    Database db = await openDatabase(
        path,
        version: Constants().dbVersion,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, mail TEXT, tel TEXT, date TEXT)"
          );
        });

    /// SQLの実行
    List<Map> result = await db.rawQuery('SELECT * FROM ${Constants().tableName}');

    /// データの取り出し

    for (Map item in result) {
      list.add(ListTile(
        title: Text(item['name']),
        subtitle: Text(item['mail'] + ' ' + item['tel']),
        trailing: Text(item['date']),
      ));
    }
    _dateT = uke;
    /// ウィジェットの更新
    setState(() {
      _items = list;
    });
  }
}