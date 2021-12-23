import 'package:flutter/material.dart';
import 'package:chutoreal/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class SecondScreen extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class WeightData {
  final DateTime date;
  final double weight;

  WeightData(this.date, this.weight);
}

///表示するページ
class _GraphPageState extends State<SecondScreen> {
  static int Date_year = 0;
  static int Date_month = 0;
  static int Date_day = 0;

  static int db_max = 0;

  static List<double> wei = [];
  static List<DateTime> dat = [];
  late Stream<int> a;
  late Stream<int> ww;

  static List<double> weight_list = new List.filled(1000, 0);
  static List<int> year_list = new List.filled(1000, 0);
  static List<int> month_list = new List.filled(1000, 0);
  static List<int> day_list = new List.filled(1000, 0);

  @override
  void initState() {
    getItems();
    dateset();
    super.initState();
    getItems();
    dateset();
  }

  void dateset() {
    for (int i = 0; i < dat.length; i++) {
      Date_year = int.parse((DateFormat('yyyy')).format(dat[i]));
      Date_month = int.parse((DateFormat('MM')).format(dat[i]));
      Date_day = int.parse((DateFormat('dd')).format(dat[i]));

      db_max = dat.length - 1;

      year_list[i] = (Date_year);
      month_list[i] = (Date_month);
      day_list[i] = (Date_day);
      weight_list[i] = wei[i];
    }
  }

  void onRefresh() {
    setState(() {
      getItems();
      dateset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('記録初日と最終記録日の比較'),
          Container(
            height: 400,
            //グラフ表示部分
            child: charts.TimeSeriesChart(
              _createWeightData(weightList),
            ),
          ),
          ElevatedButton(
              child: const Text('更新する'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF5CC31), //ボタンの背景色
              ),
              onPressed: () async {
                onRefresh();
                final newListText = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    // 遷移先の画面としてリスト追加画面を指定
                    return SecondScreen();
                  }),
                );
              }),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            Navigator.pushNamed(context, '/gacha');
          }
        },
      ),
    );
  }

  List<WeightData> weightList = <WeightData>[
    WeightData(
        DateTime(year_list[0], month_list[0], day_list[0]), weight_list[0]),
    WeightData(
        DateTime(year_list[db_max], month_list[db_max], day_list[db_max]),
        weight_list[db_max]),
  ];

//上のリストからグラフに表示させるデータを生成
  List<charts.Series<WeightData, DateTime>> _createWeightData(
      List<WeightData> weightList) {
    return [
      charts.Series<WeightData, DateTime>(
        id: 'Muscles',
        data: weightList,
        colorFn: (_, __) => charts.MaterialPalette.pink.shadeDefault,
        domainFn: (WeightData weightData, _) => weightData.date,
        measureFn: (WeightData weightData, _) => weightData.weight,
      )
    ];
  }

  /// 保存したデータを取り出す
  void getItems() async {
    /// データベースのパスを取得
    DateTime uke = DateTime.now();
    List<Widget> list = <Widget>[];
    List<double> weilist = [];
    List<DateTime> datlis = [];

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
      weilist.add(double.parse(item['weight']));
      datlis.add(DateTime.parse(item['date']));
    }

    /// ウィジェットの更新
    setState(() {
      dat = datlis;
      wei = weilist;
    });
  }
}
