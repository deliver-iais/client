import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/call_event_extension.dart';
import 'package:hive/hive.dart';

part 'current_call_info_hive.g.dart';

@HiveType(typeId: CURRENT_CALL_INFO_TRACK_ID)
class CurrentCallInfoHive {
  static const String CURRENT_CALL_ID = "1";

  @HiveField(0)
  String id;

  @HiveField(1)
  String from;

  @HiveField(2)
  String to;

  @HiveField(3)
  String callEvent;

  @HiveField(4)
  String offerBody;

  @HiveField(5)
  String offerCandidate;

  @HiveField(6)
  int expireTime;

  @HiveField(7)
  bool notificationSelected;

  @HiveField(8)
  bool isAccepted;

  CurrentCallInfoHive({
    required this.id,
    required this.callEvent,
    required this.from,
    required this.to,
    required this.expireTime,
    required this.notificationSelected,
    required this.isAccepted,
    this.offerBody = "",
    this.offerCandidate = "",
  });

  CurrentCallInfoHive copyWith({
    String? id,
    String? from,
    String? to,
    String? callEvent,
    String? offerBody,
    String? offerCandidate,
    int? expireTime,
    bool? notificationSelected,
    bool? isAccepted,
  }) =>
      CurrentCallInfoHive(
        id: id ?? this.id,
        from: from ?? this.from,
        to: to ?? this.to,
        callEvent: callEvent ?? this.callEvent,
        offerBody: offerBody ?? this.offerBody,
        offerCandidate: offerCandidate ?? this.offerCandidate,
        expireTime: expireTime ?? this.expireTime,
        notificationSelected: notificationSelected ?? this.notificationSelected,
        isAccepted: isAccepted ?? this.isAccepted,
      );

  CurrentCallInfo fromHive() => CurrentCallInfo(
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

extension CurrentCallInfoHiveMapper on CurrentCallInfo {
  CurrentCallInfoHive toHive() => CurrentCallInfoHive(
        id: CurrentCallInfoHive.CURRENT_CALL_ID,
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
