import 'package:deliver/box/broadcast_member_type.dart';
import 'package:deliver/shared/extensions/phone_number_extention.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'broadcast_member.g.dart';

part 'broadcast_member.freezed.dart';

@freezed
class BroadcastMember with _$BroadcastMember {
  const factory BroadcastMember({
    @UidJsonKey required Uid broadcastUid,
    @NullableUidJsonKey Uid? memberUid,
    @NullablePhoneNumberJsonKey PhoneNumber? phoneNumber,
    @Default(BroadCastMemberType.MESSAGE) BroadCastMemberType type,
    @Default("") String name,
  }) = _BroadcastMember;

  factory BroadcastMember.fromJson(Map<String, Object?> json) =>
      BroadcastMember.fromJson(json);
}
