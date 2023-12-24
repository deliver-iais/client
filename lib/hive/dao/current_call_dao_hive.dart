import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/current_call_info_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/hive/current_call_info_hive.dart';
import 'package:hive/hive.dart';



class CurrentCallInfoDaoImpl extends CurrentCallInfoDao {
  @override
  Future<CurrentCallInfo?> get() async {
    final box = await _open();

    //here we just have one index and one data
    return box
        .get(
          CurrentCallInfoHive.CURRENT_CALL_ID,
        )
        ?.fromHive();
  }

  @override
  Future<void> save(
    CurrentCallInfo currentCallInfo,
  ) async {
    final box = await _open();

    return box.put(
      CurrentCallInfoHive.CURRENT_CALL_ID,
      currentCallInfo.toHive(),
    );
  }

  @override
  Future<void> remove() async {
    final box = await _open();

    return box.delete(
      CurrentCallInfoHive.CURRENT_CALL_ID,
    );
  }

  @override
  Stream<CurrentCallInfo?> watchCurrentCall() async* {
    final box = await _open();

    yield box.get(CurrentCallInfoHive.CURRENT_CALL_ID)?.fromHive();

    yield* box.watch().map((event) {
      return box.get(CurrentCallInfoHive.CURRENT_CALL_ID)?.fromHive();
    });
  }

  @override
  Future<void> clear() async {
    final box = await _open();

    return box.clear();
  }

  @override
  Future<void> saveCallOffer(
    String callOfferBody,
    String callOfferCandidate,
  ) async {
    final box = await _open();
    final callInfo = box.get(CurrentCallInfoHive.CURRENT_CALL_ID);
    callInfo!.offerBody = callOfferBody;
    callInfo.offerCandidate = callOfferCandidate;
    return box.put(
      CurrentCallInfoHive.CURRENT_CALL_ID,
      callInfo,
    );
  }

  @override
  Future<void> saveAcceptOrSelectNotification({
    bool isAccepted = false,
    bool isSelectNotification = false,
  }) async {
    final box = await _open();
    final callInfo = box.get(CurrentCallInfoHive.CURRENT_CALL_ID);
    callInfo!.isAccepted = isAccepted;
    callInfo.notificationSelected = isSelectNotification;
    return box.put(
      CurrentCallInfoHive.CURRENT_CALL_ID,
      callInfo,
    );
  }

  static String _key() => "current-call-info";

  Future<BoxPlus<CurrentCallInfoHive>> _open() {
    DBManager.open(
      _key(),
      TableInfo.CURRENT_CALL_INFO_TABLE_NAME,
    );
    return gen(
      Hive.openBox<CurrentCallInfoHive>(_key()),
    );
  }
}
