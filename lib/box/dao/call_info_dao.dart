import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/hive_plus.dart';

import 'package:hive/hive.dart';

abstract class CallInfoDao {
  Future<List<CallInfo>> getAll();

  Future<void> save(CallInfo callList);

  Stream<List<CallInfo>> watchAllCalls();
}

class CallInfoDaoImpl implements CallInfoDao {
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

  static Future<BoxPlus<CallInfo>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<CallInfo>(_key()));
  }
}
