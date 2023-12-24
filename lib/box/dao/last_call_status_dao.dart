import 'package:deliver/box/last_call_status.dart';

abstract class LastCallStatusDao {
  Future<LastCallStatus?> get(int callSlot);

  Future<bool?> isExist(String callId, String roomUid);

  Future<void> save(
    LastCallStatus lastCallStatus,
  );
}
