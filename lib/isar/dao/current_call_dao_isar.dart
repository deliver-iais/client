import 'dart:async';

import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/current_call_info_dao.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/isar/current_call_info_isar.dart';
import 'package:isar/isar.dart';

class CurrentCallInfoDaoImpl extends CurrentCallInfoDao {
  Isar? currentCallInfo;

  Future<Isar> _openPendingMessageIsar() => IsarManager.open();

  @override
  Future<CurrentCallInfo?> get() async {
    final box = await _openPendingMessageIsar();

    //here we just have one index and one data
    return (await box.currentCallInfoIsars
            .get(CurrentCallInfoIsar.CURRENT_CALL_ID))
        ?.fromIsar();
  }

  @override
  Future<void> save(
    CurrentCallInfo currentCallInfo,
  ) async {
    final box = await _openPendingMessageIsar();

    return box.writeTxn(() async {
      await box.currentCallInfoIsars.put(currentCallInfo.toIsar());
    });
  }

  @override
  Future<void> remove() async {
    final box = await _openPendingMessageIsar();

    return box.writeTxn(
      () =>
          box.currentCallInfoIsars.delete(CurrentCallInfoIsar.CURRENT_CALL_ID),
    );
  }

  @override
  Stream<CurrentCallInfo?> watchCurrentCall() async* {
    try {
      final box = await _openPendingMessageIsar();

      yield (await box.currentCallInfoIsars
              .get(CurrentCallInfoIsar.CURRENT_CALL_ID))
          ?.fromIsar();

      yield* box.currentCallInfoIsars
          .watchObject(
            CurrentCallInfoIsar.CURRENT_CALL_ID,
            fireImmediately: true,
          )
          .map((event) => event?.fromIsar());
    } catch (_) {}
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
    return box.writeTxn(() async {
      await box.currentCallInfoIsars.put(callInfo);
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
    return box.writeTxn(() async {
      await box.currentCallInfoIsars.put(callInfo);
    });
  }
}
