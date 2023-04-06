import 'package:deliver/box/call_data_usage.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class CallDataUsageDao {
  Future<CallDataUsage?> get(String callId);

  Future<void> save(CallDataUsage callDataUsage);
}

class CallDataUsageDaoImpl extends CallDataUsageDao {
  @override
  Future<CallDataUsage?> get(String callId) async {
    final box = await _open();

    return box.get(callId);
  }

  @override
  Future<void> save(CallDataUsage callDataUsage) async {
    final box = await _open();

    return box.put(callDataUsage.callId, callDataUsage);
  }

  static String _key() => "call_data_usage";

  Future<BoxPlus<CallDataUsage>> _open() {
    DBManager.open(_key(), TableInfo.CALL_DATA_USAGE_TABLE_NAME);
    return gen(Hive.openBox<CallDataUsage>(_key()));
  }
}
