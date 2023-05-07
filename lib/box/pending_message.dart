import 'package:deliver/box/message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_message.freezed.dart';
part 'pending_message.g.dart';

@freezed
class PendingMessage with _$PendingMessage {
  const factory PendingMessage({
    @UidJsonKey required Uid roomUid,
    required String packetId,
    @MessageJsonKey required Message msg,
    @Default(false) bool failed,
    required SendingStatus status,
  }) = _PendingMessage;

  factory PendingMessage.fromJson(Map<String, Object?> json) =>
      _$PendingMessageFromJson(json);
}
