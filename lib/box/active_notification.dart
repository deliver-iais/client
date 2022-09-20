import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'active_notification.g.dart';

@HiveType(typeId: ACTIVE_NOTIFICATION_TRACK_ID)
class ActiveNotification {
  @HiveField(0)
  String roomUid;

  @HiveField(1)
  int messageId;

  @HiveField(2)
  String roomName;

  @HiveField(3)
  String messageText;

  ActiveNotification({
    required this.roomUid,
    required this.messageId,
    required this.messageText,
    required this.roomName,
  });

  ActiveNotification copyWith({
    String? roomUid,
    int? messageId,
    String? roomName,
    String? messageText,
  }) =>
      ActiveNotification(
        roomUid: roomUid ?? this.roomUid,
        messageId: messageId ?? this.messageId,
        roomName: roomName ?? this.roomName,
        messageText: messageText ?? this.messageText,
      );
}
