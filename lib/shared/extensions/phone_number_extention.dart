import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

const PhoneNumberJsonKey = JsonKey(fromJson: fromJson, toJson: toJson);

const NullablePhoneNumberJsonKey = JsonKey(
  fromJson: nullAblePhoneNumberFromJson,
  toJson: nullablePhoneNumberToJson,
);

PhoneNumber fromJson(String json) {
  return PhoneNumber.fromJson(json);
}

PhoneNumber? nullAblePhoneNumberFromJson(String? json) {
  return json != null ? PhoneNumber.fromJson(json) : null;
}

String toJson(PhoneNumber protobufModel) {
  return protobufModel.writeToJson();
}

String? nullablePhoneNumberToJson(PhoneNumber? protobufModel) {
  return protobufModel?.writeToJson();
}

extension StringPhoneNumberExtension on String {
  PhoneNumber asPhoneNumber() => PhoneNumber.fromJson(this);
}

extension PhoneNumberExtension on PhoneNumber {
  String asString() => writeToJson();
}
