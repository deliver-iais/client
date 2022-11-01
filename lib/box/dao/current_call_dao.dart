import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class CurrentCallInfoDao extends DBManager {
  Future<CurrentCallInfo?> get();

  Future<void> save(CurrentCallInfo currentCallInfo);

  Future<void> remove();

  Stream<CurrentCallInfo?> watchCurrentCall();

  Future<void> clear();
}

class CurrentCallInfoDaoImpl extends CurrentCallInfoDao {
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

  Future<BoxPlus<CurrentCallInfo>> _open() {
    super.open(_key(), CURRENT_CALL_INFO_TABLE_NAME);
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
