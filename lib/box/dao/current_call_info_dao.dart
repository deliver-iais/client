import 'package:deliver/box/current_call_info.dart';

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
