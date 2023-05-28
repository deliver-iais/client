import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/shared/extensions/call_event_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:isar/isar.dart';

part 'current_call_info_isar.g.dart';

@collection
class CurrentCallInfoIsar {
  static const int CURRENT_CALL_ID = 1;

  Id id = CURRENT_CALL_ID;

  String from;

  String to;

  String callEvent;

  String offerBody;

  String offerCandidate;

  int expireTime;

  bool notificationSelected;

  bool isAccepted;

  CurrentCallInfoIsar({
    required this.callEvent,
    required this.from,
    required this.to,
    required this.expireTime,
    required this.notificationSelected,
    required this.isAccepted,
    this.offerBody = "",
    this.offerCandidate = "",
  });

  CurrentCallInfo fromIsar() => CurrentCallInfo(
        from: from,
        to: to,
        callEvent: callEventV2FromJson(callEvent),
        offerBody: offerBody,
        offerCandidate: offerCandidate,
        expireTime: expireTime,
        notificationSelected: notificationSelected,
        isAccepted: isAccepted,
      );
}

extension CurrentCallInfoIsarMapper on CurrentCallInfo {
  CurrentCallInfoIsar toIsar() => CurrentCallInfoIsar(
        from: from,
        to: to,
        callEvent: callEventV2ToJson(callEvent),
        offerBody: offerBody,
        offerCandidate: offerCandidate,
        expireTime: expireTime,
        notificationSelected: notificationSelected,
        isAccepted: isAccepted,
      );
}
