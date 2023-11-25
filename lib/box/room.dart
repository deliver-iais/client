import 'package:deliver/box/message.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';

part 'room.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    @UidJsonKey required Uid uid,
    @NullableMessageJsonKey Message? lastMessage,
    String? replyKeyboardMarkup,
    @Default("") String draft,
    @Default([]) List<int> mentionsId,
    @Default(0) int lastUpdateTime,
    @Default(0) int lastMessageId,
    @Default(0) int localNetworkMessageCount,
    @Default(0) int lastLocalNetworkMessageId,
    @Default(0) int firstMessageId,
    @Default(0) int pinId,
    @Default(0) int lastCurrentUserSentMessageId,
    @Default(false) bool deleted,
    @Default(false) bool pinned,
    @Default(false) bool synced,
    @Default(false) bool seenSynced,
    @Default(true) bool shouldUpdateMediaCount,
  }) = _Room;

  factory Room.fromJson(Map<String, Object?> json) => Room.fromJson(json);
}
