import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/call_info.dart';

import 'package:hive/hive.dart';

abstract class CallInfoDao {
  Future<List<CallInfo>> getAll();

  Future<void> save(CallInfo callList);
}

class CallInfoDaoImpl implements CallInfoDao {
  @override
  Future<List<CallInfo>> getAll() async {
    var box = await _open();

    return box.values.toList();
  }

  @override
  Future<void> save(CallInfo callList) async {
    var box = await _open();

    return box.put(callList.callEvent.id, callList);
  }

  static String _key() => "call_list";

  static Future<Box<CallInfo>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<CallInfo>(_key());
  }
}
