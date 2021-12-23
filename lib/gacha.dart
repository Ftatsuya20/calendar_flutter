import 'package:flutter/material.dart';
import 'package:chutoreal/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chutoreal/gacha_kekka.dart';

class gachapage extends StatefulWidget {
  @override
  _gachapageState createState() => _gachapageState();
}

class _gachapageState extends State<gachapage> {
  List<int> money = [100, 200, 500];
  List<double> weight_List = [0, 1];

  int hantei = 0;
  String hantei_message = "";

  @override
  void initState() {
    super.initState();
    getItems();
  }

  void gacha_setting() {
    if ((weight_List[weight_List.length - 1] -
            weight_List[weight_List.length - 2]) <=
        0) {
      hantei = 1;
      hantei_message = "あなたは前日より痩せました！";
    } else {
      hantei = 0;
      hantei_message = "あなたは前日より太りました";
    }
  }

  @override
  Widget build(BuildContext context) {
    gacha_setting();
    return Scaffold(
      appBar: AppBar(
        title: Text('ポイント発行'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(hantei_message),
          Container(
            child: ElevatedButton(
                child: const Text('ガチャを引く'),
                onPressed: () async {
                  if (hantei == 0) {
                    var result = await showDialog<int>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('確認'),
                          content: Text('ガチャが引けません'),
                          actions: <Widget>[
                            TextButton(
                                child: Text('OK'),
                                onPressed: () async {
                                  final newListText =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      // 遷移先の画面としてリスト追加画面を指定
                                      return gachapage();
                                    }),
                                  );
                                }),
                          ],
                        );
                      },
                    );
                    print('dialog result: $result');
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        // 遷移先の画面としてリスト追加画面を指定
                        return gachakekkaPage();
                      }),
                    );
                  }
                }),
          )
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(title: Text("追加"), icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              title: Text('グラフ'), icon: Icon(Icons.trending_down)),
          BottomNavigationBarItem(title: Text('ガチャ'), icon: Icon(Icons.star))
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else {
            Navigator.pushNamed(context, '/list');
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
    List<double> weight_list = [];

    String dbFilePath = await getDatabasesPath();
    String path = join(dbFilePath, Constants().dbName);

    /// テーブルがなければ作成する
    Database db = await openDatabase(path, version: Constants().dbVersion,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, memo TEXT, weight TEXT, date TEXT)");
    });

    /// SQLの実行
    List<Map> result =
        await db.rawQuery('SELECT * FROM ${Constants().tableName}');

    /// データの取り出し

    for (Map item in result) {
      weight_list.add(double.parse(item['weight']));
    }

    /// ウィジェットの更新
    setState(() {
      weight_List = weight_list;
    });
  }
}
