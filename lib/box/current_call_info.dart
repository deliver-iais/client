import 'package:deliver/shared/extensions/call_event_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_call_info.freezed.dart';

part 'current_call_info.g.dart';

@freezed
class CurrentCallInfo with _$CurrentCallInfo {
  const factory CurrentCallInfo({
    @CallEventV2JsonKey required CallEventV2 callEvent,
    required String from,
    required String to,
    required int expireTime,
    required bool notificationSelected,
    required bool isAccepted,
    @Default("") String offerBody,
    @Default("") String offerCandidate,
  }) = _CurrentCallInfo;

  factory CurrentCallInfo.fromJson(Map<String, Object?> json) =>
      _$CurrentCallInfoFromJson(json);
}
