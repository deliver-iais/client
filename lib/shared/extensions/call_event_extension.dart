import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

const CallEventV2JsonKey = JsonKey(fromJson: callEventV2FromJson, toJson: callEventV2ToJson);

CallEventV2 callEventV2FromJson(String json) {
  return CallEventV2.fromJson(json);
}

String callEventV2ToJson(CallEventV2 protobufModel) {
  return protobufModel.writeToJson();
}
