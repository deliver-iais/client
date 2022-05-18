import 'package:hive/hive.dart';

import '../box_info.dart';
import '../current_call_info.dart';
import '../hive_plus.dart';

abstract class CurrentCallInfoDao {
  Future<CurrentCallInfo?> get();

  Future<void> save(CurrentCallInfo currentCallInfo);

  Future<void> remove();

  Stream<CurrentCallInfo?> watchCurrentCall();

  Future<void> clear();
}

class CurrentCallInfoDaoImpl implements CurrentCallInfoDao {
  @override
  Future<CurrentCallInfo?> get() async {
    final box = await _open();

    return box.get("current_call_id");
  }

  @override
  Future<void> save(CurrentCallInfo currentCallInfo) async {
    final box = await _open();

    return box.put("current_call_id", currentCallInfo);
  }

  static String _key() => "current_call";

  static Future<BoxPlus<CurrentCallInfo>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<CurrentCallInfo>(_key()));
  }

  @override
  Future<void> remove() async {
    final box = await _open();

    return box.delete("current_call_id");
  }

  @override
  Stream<CurrentCallInfo?> watchCurrentCall() async* {
    final box = await _open();

    yield box.get("current_call_id");

    yield* box.watch().map((event) => box.get("current_call_id"));
  }

  @override
  Future<void> clear() async {
    final box = await _open();

    return box.clear();
  }
}
