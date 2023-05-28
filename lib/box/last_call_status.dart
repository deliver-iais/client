import 'package:freezed_annotation/freezed_annotation.dart';

part 'last_call_status.freezed.dart';

part 'last_call_status.g.dart';

@freezed
class LastCallStatus with _$LastCallStatus {
  const factory LastCallStatus({
    required int id,
    required String callId,
    required String roomUid,
    required int expireTime,
  }) = _LastCallStatus;

  factory LastCallStatus.fromJson(Map<String, Object?> json) =>
      _$LastCallStatusFromJson(json);
}
