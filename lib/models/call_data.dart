import 'package:json_annotation/json_annotation.dart';

part 'call_data.g.dart';

@JsonSerializable()
class CallData {
  final String callId;
  final String roomUid;
  final int expireTime;

  CallData({
    required this.callId,
    required this.roomUid,
    required this.expireTime,
  });

  /// Connect the generated [_$CallDataFromJson] function to the `fromJson`
  /// factory.
  factory CallData.fromJson(Map<String, dynamic> json) =>
      _$CallDataFromJson(json);

  /// Connect the generated [_$CallDataToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$CallDataToJson(this);
}
