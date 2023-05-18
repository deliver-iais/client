import 'package:collection/collection.dart';
import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'broadcast_status.g.dart';

@HiveType(typeId: BROADCAST_STATUS_TRACK_ID)
class BroadcastStatus {
  @HiveField(0)
  int broadcastMessageId;

  //is uuid for we message and firstname-lastname for sms message
  @HiveField(1)
  String to;

  @HiveField(2)
  BroadcastMessageStatusType status;

  // is packet id for we message and phone number for sms message
  @HiveField(3)
  String sendingId;

  @HiveField(4)
  bool isSmsBroadcast;

  BroadcastStatus({
    required this.broadcastMessageId,
    required this.to,
    required this.status,
    required this.sendingId,
    this.isSmsBroadcast = false,
  });

  BroadcastStatus copy(BroadcastStatus bc) => BroadcastStatus(
        broadcastMessageId: bc.broadcastMessageId,
        to: bc.to,
        status: bc.status,
        sendingId: bc.sendingId,
        isSmsBroadcast: bc.isSmsBroadcast,
      );

  BroadcastStatus copyWith({
    int? broadcastMessageId,
    String? to,
    BroadcastMessageStatusType? status,
    String? sendingId,
    bool? isSmsBroadcast,
  }) =>
      BroadcastStatus(
        broadcastMessageId: broadcastMessageId ?? this.broadcastMessageId,
        to: to ?? this.to,
        status: status ?? this.status,
        sendingId: sendingId ?? this.sendingId,
        isSmsBroadcast: isSmsBroadcast ?? this.isSmsBroadcast,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BroadcastStatus &&
            const DeepCollectionEquality()
                .equals(other.broadcastMessageId, broadcastMessageId) &&
            const DeepCollectionEquality().equals(other.to, to) &&
            const DeepCollectionEquality().equals(other.sendingId, sendingId) &&
            const DeepCollectionEquality()
                .equals(other.isSmsBroadcast, isSmsBroadcast) &&
            const DeepCollectionEquality().equals(other.status, status));
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(broadcastMessageId),
        const DeepCollectionEquality().hash(status),
        const DeepCollectionEquality().hash(sendingId),
        const DeepCollectionEquality().hash(isSmsBroadcast),
        const DeepCollectionEquality().hash(to),
      );

  @override
  String toString() {
    return 'BroadcastStatus{broadcastMessageId: $broadcastMessageId, to: $to, status: $status, packetId: $sendingId}';
  }
}
