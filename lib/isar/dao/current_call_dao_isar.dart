import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/isar/current_call_info_isar.dart';
import 'package:isar/isar.dart';

abstract class CurrentCallInfoDao {
  Future<CurrentCallInfo?> get();

  Future<void> save(
    CurrentCallInfo currentCallInfo,
  );

  Future<void> saveAcceptOrSelectNotification({
    bool isAccepted = false,
    bool isSelectNotification = false,
  });

  Future<void> saveCallOffer(
    String callOfferBody,
    String callOfferCandidate,
  );

  Future<void> remove();

  Stream<CurrentCallInfo?> watchCurrentCall();

  Future<void> clear();
}

class CurrentCallInfoDaoImpl extends CurrentCallInfoDao {
  Isar? currentCallInfo;

  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<CurrentCallInfo?> get() async {
    final box = await _openPendingMessageIsar();

    //here we just have one index and one data
    return box.currentCallInfoIsars
        .getSync(CurrentCallInfoIsar.CURRENT_CALL_ID)
        ?.fromIsar();
  }

  @override
  Future<void> save(
    CurrentCallInfo currentCallInfo,
  ) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.currentCallInfoIsars.putSync(currentCallInfo.toIsar());
    });
  }

  @override
  Future<void> remove() async {
    final box = await _openPendingMessageIsar();

    return box.writeTxnSync(() {
      box.currentCallInfoIsars.deleteSync(CurrentCallInfoIsar.CURRENT_CALL_ID);
    });
  }

  @override
  Stream<CurrentCallInfo?> watchCurrentCall() async* {
    final box = await _openPendingMessageIsar();

    yield box.currentCallInfoIsars
        .getSync(CurrentCallInfoIsar.CURRENT_CALL_ID)
        ?.fromIsar();

    yield* box.currentCallInfoIsars
        .watchObject(CurrentCallInfoIsar.CURRENT_CALL_ID, fireImmediately: true)
        .map((event) => event?.fromIsar());
  }

  @override
  Future<void> clear() async {
    final box = await _openPendingMessageIsar();

    return box.clear();
  }

  @override
  Future<void> saveCallOffer(
    String callOfferBody,
    String callOfferCandidate,
  ) async {
    final box = await _openPendingMessageIsar();
    final callInfo =
        await box.currentCallInfoIsars.get(CurrentCallInfoIsar.CURRENT_CALL_ID);
    callInfo!.offerBody = callOfferBody;
    callInfo.offerCandidate = callOfferCandidate;
    return box.writeTxnSync(() async {
      box.currentCallInfoIsars.putSync(callInfo);
    });
  }

  @override
  Future<void> saveAcceptOrSelectNotification({
    bool isAccepted = false,
    bool isSelectNotification = false,
  }) async {
    final box = await _openPendingMessageIsar();
    final callInfo =
        await box.currentCallInfoIsars.get(CurrentCallInfoIsar.CURRENT_CALL_ID);
    callInfo!.isAccepted = isAccepted;
    callInfo.notificationSelected = isSelectNotification;
    return box.writeTxnSync(() async {
      box.currentCallInfoIsars.putSync(callInfo);
    });
  }
}
