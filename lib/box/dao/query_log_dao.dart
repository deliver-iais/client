import 'dart:async';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/query_log.dart';
import 'package:hive/hive.dart';


class QueryLogDao {
  static String _keyQueryLog() => "query_log";

  Stream<List<QueryLog>?>  watchQueryLogs() async*{

      final box = await _openQueryLog();

      yield box.values.toList();
      yield* box.watch().map(
            (event) => box.values.toList(),
      );
   }

   Future<void> updateQueryLog(String address, int count) async {
     final box = await _openQueryLog();

     int value = count;

     if(box.containsKey(address) && box.get(address)!= null) {
       value += box.get(address)!.count;
     }

     await box.put(address, QueryLog(address: address, count: value));
   }

   Future<BoxPlus<QueryLog>> _openQueryLog() async {
     try {
       DBManager.open(_keyQueryLog(), TableInfo.QUERY_LOG_TABLE_NAME);
       return await gen(Hive.openBox<QueryLog>(_keyQueryLog()));
     } catch (e) {
       await Hive.deleteBoxFromDisk(_keyQueryLog());
       return await gen(Hive.openBox<QueryLog>(_keyQueryLog()));
     }
   }


}