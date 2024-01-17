import 'dart:convert';

import 'package:deliver/box/message_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

part 'message.g.dart';

const MessageJsonKey =
    JsonKey(fromJson: getMessageFromJson, toJson: messageToJson);

const NullableMessageJsonKey = JsonKey(
  fromJson: getNullableMessageFromJson,
  toJson: nullableMessageToJson,
);

String messageToJson(Message model) {
  return jsonEncode(model.toJson());
}

String? nullableMessageToJson(Message? model) {
  return model != null ? jsonEncode(model.toJson()) : null;
}

@freezed
class Message with _$Message {
  const factory Message({
    @UidJsonKey required Uid roomUid,
    @UidJsonKey required Uid from,
    @UidJsonKey required Uid to,
    required String packetId,
    required int time,
    required String json,
    @Default(0) int replyToId,
    @Default(MessageType.NOT_SET) MessageType type,
    @Default(false) bool edited,
    @Default(false) bool encrypted,
    @Default(false) bool isHidden,
    @Default(false) bool isLocalMessage,
    @Default(false) bool needToBackup,
    String? markup,
    int? id,
    int? localNetworkMessageId,
    @NullableUidJsonKey Uid? forwardedFrom,
    @NullableUidJsonKey Uid? generatedBy,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}

extension MessageMapper on Message {
  Message copyDeleted() => copyWith(json: EMPTY_MESSAGE, isHidden: true);
}

Message getMessageFromJson(String msgJson) {
  return _$MessageFromJson(jsonDecode(msgJson));
}

Message? getNullableMessageFromJson(String? msgJson) {
  return (msgJson != null && msgJson.isNotEmpty)
      ? _$MessageFromJson(jsonDecode(msgJson))
      : null;
}
