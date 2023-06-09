
import 'package:deliver/box/role.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.g.dart';
part 'member.freezed.dart';


@freezed
class Member with _$Member {
  const factory Member ({
    @UidJsonKey required Uid mucUid,
    @UidJsonKey required Uid memberUid,
    @Default(MucRole.NONE) MucRole role,

  }) = _Member;

  factory Member.fromJson(Map<String, Object?> json) => Member.fromJson(json);




}
