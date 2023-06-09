import 'package:deliver/shared/extensions/phone_number_extention.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact.freezed.dart';
part 'contact.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    @PhoneNumberJsonKey required PhoneNumber phoneNumber,
    @NullableUidJsonKey Uid? uid,
    @Default("") String firstName,
    @Default("") String lastName,
    @Default("") String description,
    @Default(0) int syncHash,
    @Default(0) int updateTime,
  }) = _Contact;

  factory Contact.fromJson(Map<String, Object?> json) =>
      _$ContactFromJson(json);
}
