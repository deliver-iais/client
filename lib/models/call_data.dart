import 'package:json_annotation/json_annotation.dart';

part 'call_data.g.dart';

@JsonSerializable()
class CallData {
  final String callId;
  final String roomUid;
  final int expireTime;

  const CallData({
    required this.callId,
    required this.roomUid,
    required this.expireTime,
  });

  static const defaultInstance = CallData(
    callId: "",
    roomUid: "",
    expireTime: 0,
  );
}

const CallDataFromJson = _$CallDataFromJson;
const CallDataToJson = _$CallDataToJson;