import 'package:deliver/box/member.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'member_isar.g.dart';

@collection
class MemberIsar {
  Id get dbId => fastHash("$mucUid$memberUid");

  String mucUid;

  String memberUid;

  String username;

  String realName;

  String name;

  @enumerated
  MucRole role;

  MemberIsar({
    required this.mucUid,
    required this.memberUid,
    this.role = MucRole.NONE,
    this.username = "",
    this.realName = "",
    this.name = "",
  });

  Member fromIsar() => Member(
        mucUid: mucUid.asUid(),
        memberUid: memberUid.asUid(),
        role: role,
        username: username,
        realName: realName,
        name: name,
      );
}

extension MemberIsarMapper on Member {
  MemberIsar toIsar() => MemberIsar(
        mucUid: mucUid.asString(),
        memberUid: memberUid.asString(),
        role: role,
        username: username,
        realName: realName,
        name: name,
      );
}
