import 'package:deliver/box/broadcast_member.dart';
import 'package:deliver/box/broadcast_member_type.dart';
import 'package:deliver/shared/extensions/phone_number_extention.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'broadcast_member_isar.g.dart';

@collection
class BroadcastMemberIsar {
  Id id = Isar.autoIncrement;

  String broadcastUid;

  String? memberUid;

  String? phoneNumber;

  String name;

  @enumerated
  BroadCastMemberType type;

  BroadcastMemberIsar({
    required this.broadcastUid,
    this.memberUid,
    this.phoneNumber,
    this.name = "",
    this.type = BroadCastMemberType.MESSAGE,
  });

  BroadcastMember fromIsar() => BroadcastMember(
        broadcastUid: broadcastUid.asUid(),
        memberUid: memberUid?.asUid(),
        phoneNumber: phoneNumber?.asPhoneNumber(),
        name:name,
        type: type,
      );
}

extension MemberIsarMapper on BroadcastMember {
  BroadcastMemberIsar toIsar() => BroadcastMemberIsar(
        broadcastUid: broadcastUid.asString(),
        memberUid: memberUid?.asString(),
        name: name,
        phoneNumber: phoneNumber?.asString(),
        type: type,
      );
}
