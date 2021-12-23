import 'dart:collection';

import 'package:chutoreal/addpage.dart';
import 'package:chutoreal/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

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
  void initState() {
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
      _eventsList.addAll({
        DateTTT[i]: _items[i],
      });
    }
  }

  void _deleteData(itemId) async {
    String dbFilePath = await getDatabasesPath();
    String path = join(dbFilePath, Constants().dbName);

    Database db = await openDatabase(path, version: Constants().dbVersion,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${Constants().tableName} (id INTEGER PRIMARY KEY, memo TEXT, mail TEXT, date TEXT)");
    });

    print(itemId);

    await db
        .delete(Constants().tableName, where: 'date = ?', whereArgs: [itemId]);
  }

  void onRefresha() {
    setState(() {
      getItems();
      addlis();
      DateTime updated_at = new DateTime.now();
      print(updated_at);
      final _events = LinkedHashMap<DateTime, List>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(_eventsList);
    });
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 5,
      bottom: 5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[700],
        ),
        width: 16.0,
        height: 16.0,
        child: Center(
          child: Text(
            '✓',
            style: TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getItems();

    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    getDate() {
      _events.forEach((key, value) {
        String Storing_key;
        Storing_key = '$key';
        DateTime datetime = DateTime.parse(Storing_key);
        change_key = (DateFormat('MM-dd-yyyy')).format(datetime);

        String change_selectedDay =
            (DateFormat('MM-dd-yyyy')).format(_selectedDay!);

        if (change_key == change_selectedDay) {
          Delete_key = '$key';
        }
      });
    }

    List _getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(color: Colors.white),
          ),
          TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFFF3567E),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color(0xFFF61D58),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: const Color(0xFFFD3A4A)),
            ),
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return _buildEventsMarker(date, events);
                }
              },
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: _getEventForDay(_selectedDay!)
                .map((event) => ListTile(
                      title: Text(event.toString(),
                          style: TextStyle(
                              fontSize: 15.0,
                              decoration: TextDecoration.underline)),
                      trailing: IconButton(
                          onPressed: () async {
                            var result = await showDialog<int>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('確認'),
                                  content: Text('削除しますか？'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(0),
                                    ),
                                    TextButton(
                                        child: Text('OK'),
                                        onPressed: () async {
                                          getDate();

                                          _deleteData(Delete_key);
                                          final newListText =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                              // 遷移先の画面としてリスト追加画面を指定
                                              return CalendarScreen();
                                            }),
                                          );
                                        }),
                                  ],
                                );
                              },
                            );
                            print('dialog result: $result');
                          },
                          icon: Icon(Icons.delete, color: Colors.grey)),
                    ))
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () async {
          // "push"で新規画面に遷移
          // リスト追加画面から渡される値を受け取る
          final newListText = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // 遷移先の画面としてリスト追加画面を指定
              return FirstScreen();
            }),
          );
          if (newListText != null) {
            _eventsList.addAll({
              DateTTT[_items.length]: _items[_items.length],
            });
          }
          ;
        },
        backgroundColor: Color(0xFFF61D58),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'カレンダー',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
              label: "グラフ", icon: Icon(Icons.trending_down)),
          BottomNavigationBarItem(label: 'ガチャ', icon: Icon(Icons.star))
        ],
        currentIndex: 0,
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/list');
          } else {
            Navigator.pushNamed(context, '/gacha');
          }
        },
      ),
    );
  }

  void getItems() async {
    /// データベースのパスを取得

    List<String> Datelist = [];
    List<List> list = [];
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
      Datelist.add(item['date']);
      list.add([item['memo'], item['weight']]);
    }

    /// ウィジェットの更新
    setState(() {
      _items = list;
      dateTT = Datelist;
    });
  }
}
