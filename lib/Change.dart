import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chutoreal/addpage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chutoreal/constants.dart';


Change(){
  String? uke;
  // "2020/09/16 22:16"みたいな文字列から取る場合

   final _dateFormatter = DateFormat("y-M-d");

  // String→DateTime変換
  DateTime getDatetime(String uu){
    DateTime resultt;

    // String→DateTime変換
    try {
      resultt = _dateFormatter.parseStrict(uu);

      // (補足)
      // parseStrict()を使うのが大事。
      // parse()だと存在しない日付がいい感じ(?)に計算されて変換された
      // 例)2020/9/32を入れた場合
      // _dateFormatter.parseStrict("2020/9/32"); // 結果→Exception
      // _dateFormatter.parse("2020/9/32"); // 結果→2020/10/2のDateTimeに変換

    } catch(e){
      resultt = DateTime.now(); // 変換に失敗した場合の処理
    }

    return resultt;
  }

}