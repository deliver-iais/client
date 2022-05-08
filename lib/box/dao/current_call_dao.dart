import 'package:hive/hive.dart';

import '../box_info.dart';
import '../call_info.dart';
import '../hive_plus.dart';

abstract class CurrentCallInfoDao {
  Future<CallInfo?> get();

  Future<void> save(CallInfo callInfo);

  Future<void> remove();

  Stream<CallInfo?> watchCurrentCall();
}

class CurrentCallInfoDaoImpl implements CurrentCallInfoDao {
  @override
  Future<CallInfo?> get() async {
    final box = await _open();

    return box.get("current_call_id");
  }

  @override
  Future<void> save(CallInfo callInfo) async {
    final box = await _open();

    return box.put("current_call_id", callInfo);
  }

  static String _key() => "current_call";

  static Future<BoxPlus<CallInfo>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<CallInfo>(_key()));
  }

  @override
  Future<void> remove() async {
    final box = await _open();

    return box.delete("current_call_id");
  }

  @override
  Stream<CallInfo?> watchCurrentCall() async* {
    final box = await _open();

    yield box.get("current_call_id");

    yield* box.watch().map((event) => box.get("current_call_id"));
  }
}
