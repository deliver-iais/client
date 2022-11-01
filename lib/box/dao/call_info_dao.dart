import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';

import 'package:hive/hive.dart';

abstract class CallInfoDao extends DBManager {
  Future<List<CallInfo>> getAll();

  Future<void> save(CallInfo callList);

  Stream<List<CallInfo>> watchAllCalls();
}

class CallInfoDaoImpl extends CallInfoDao {
  @override
  Future<List<CallInfo>> getAll() async {
    final box = await _open();

    return box.values.toList();
  }

  @override
  Future<void> save(CallInfo callList) async {
    final box = await _open();

    return box.put(callList.callEvent.id, callList);
  }

  @override
  Stream<List<CallInfo>> watchAllCalls() async* {
    final box = await _open();

    yield box.values.toList();

    yield* box.watch().map(
          (event) => box.values.toList(),
        );
  }

  static String _key() => "call_list";

  Future<BoxPlus<CallInfo>> _open() {
    super.open(_key(), CALL_INFO_TABLE_NAME);
    return gen(Hive.openBox<CallInfo>(_key()));
  }
}
