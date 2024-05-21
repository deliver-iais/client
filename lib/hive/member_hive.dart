import 'package:collection/collection.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'member_hive.g.dart';

@HiveType(typeId: MEMBER_TRACK_ID)
class MemberHive {
  // Table ID
  @HiveField(0)
  String mucUid;

  // DbId
  @HiveField(1)
  String memberUid;

  @HiveField(2)
  MucRole role;

  @HiveField(3)
  String id;

  @HiveField(4)
  String name;

  MemberHive({
    required this.mucUid,
    required this.memberUid,
    this.id = "",
    this.name = "",
    this.role = MucRole.NONE,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MemberHive &&
          const DeepCollectionEquality().equals(other.mucUid, mucUid) &&
          const DeepCollectionEquality().equals(other.memberUid, memberUid) &&
          const DeepCollectionEquality().equals(other.role, role));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(mucUid),
        const DeepCollectionEquality().hash(memberUid),
        const DeepCollectionEquality().hash(role),
      );

  @override
  String toString() {
    return 'Member{mucUid: $mucUid, memberUid: $memberUid, role: $role}';
  }

  Member fromHive() => Member(
        mucUid: mucUid.asUid(),
        memberUid: memberUid.asUid(),
        username: id,
        name: name,
        role: role,
      );
}

extension MemberHiveMapper on Member {
  MemberHive toHive() => MemberHive(
      mucUid: mucUid.asString(),
      memberUid: memberUid.asString(),
      role: role,
      name: name,
      id: username);
}
