import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chutoreal/addpage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chutoreal/constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quiver/iterables.dart';




class CalendarScreen extends StatefulWidget {

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<List> _items = [];
  List dateTT = [];
  List nameuke = [];
  List<DateTime> DateTTT = [];
  String change_key = "";
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List> _eventsList = {};
  Map<int, String> dele = {};
  String Delete_key = ""; 


  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }


  @override
  void initState()  {
    super.initState();
    getItems();
    _selectedDay = _focusedDay;

    Future(() async {
      await Future.delayed(Duration(seconds: 1));
      addlis();
    });

    }

    void addlis() {


      for (int i = 0; i < _items.length; i++) {
        DateTime datetime = DateTime.parse(dateTT[i]);
        DateTTT.add(datetime);
        nameuke.add(_items[i]);
        /*dele.addAll({
          ukeId[i]: nameuke[i],
        });*/
        //print(nameuke);
        //lislis = _items[i] as List;

        //print(Storinglist);

        //hoji = {datetime:lislis};
        //_eventsList.addAll(hoji);
        //_eventsList[datetime] = storing_list;
        //print(_eventsList);
        _eventsList.addAll({
          DateTTT[i]: _items[i],
        }
        );
        /*_eventsList[datetime] = lislis;*/

      }

    }

  void _deleteData(itemId) async{

    String dbFilePath = await getDatabasesPath();
    String path = join (dbFilePath, Constants().dbName);


    Database db = await openDatabase(path, version: Constants().dbVersion, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, name TEXT, mail TEXT, tel TEXT ,date TEXT)"
      );
    });

    print(itemId);

    await db.delete(Constants().tableName,
        where:'date = ?',
        whereArgs: [itemId]);
  }





      @override
      Widget build(BuildContext context) {

          final _events = LinkedHashMap<DateTime, List>(
            equals: isSameDay,
            hashCode: getHashCode,
          )
            ..addAll(_eventsList);

           getDate() {
              //print(_selectedDay);
            _events.forEach((key, value) {
              //print('$key');

              String Storing_key;
              Storing_key = '$key';
              DateTime datetime = DateTime.parse(Storing_key);
              change_key = (DateFormat('MM-dd-yyyy')).format(datetime);

              String change_selectedDay = (DateFormat('MM-dd-yyyy')).format(_selectedDay!);


              if (change_key  == change_selectedDay) {
                Delete_key = '$key';
              }
            });
          }



          List _getEventForDay(DateTime day) {
            return _events[day] ?? [];

          }



        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('calendar sample'),
          ),
          body: Column(
            children: [
              TableCalendar(
                locale: 'ja_JP',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                eventLoader: _getEventForDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _getEventForDay(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),

              ListView(
                shrinkWrap: true,
                children: _getEventForDay(_selectedDay!)
                    .map((event) =>
                    ListTile(
                      title: Text(event.toString()),
                      trailing: IconButton(onPressed: () {
                        getDate();

                        _deleteData(Delete_key);

                      }, icon: Icon(Icons.delete)),
                    ))
                    .toList(),

              )
            ],
          ),

          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                // "push"で新規画面に遷移
                // リスト追加画面から渡される値を受け取る
                final newListText = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    // 遷移先の画面としてリスト追加画面を指定
                    return FirstScreen();
                  }),
                );

              }),

        );

      }


    void getItems() async{
      /// データベースのパスを取得

      List<String> Datelist = [];
      List<List> list = [];
      Map<int, String> aa = {};
      String dbFilePath = await getDatabasesPath();
      String path = join(dbFilePath, Constants().dbName);

      /// テーブルがなければ作成する
      Database db = await openDatabase(
          path,
          version: Constants().dbVersion,
          onCreate: (Database db, int version) async {
            await db.execute("CREATE TABLE IF NOT EXISTS ${Constants()
                .tableName} (id INTEGER PRIMARY KEY, name TEXT, mail TEXT, tel TEXT, date TEXT)"
            );
          });

      /// SQLの実行
      List<Map> result = await db.rawQuery(
          'SELECT * FROM ${Constants().tableName}');


      /// データの取り出し
      for(Map item in result) {
        Datelist.add(item['date']);
        list.add([item['name']]);
      }


      /// ウィジェットの更新
      setState(() {
        _items = list;
        dateTT = Datelist;
      });
    }
  }

