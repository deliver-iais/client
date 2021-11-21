import 'package:deliver/box/role.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: MEMBER_TRACK_ID)
class Member {
  // Table ID
  @HiveField(0)
  String mucUid;

  // DbId
  @HiveField(1)
  String memberUid;

  @HiveField(2)
  MucRole role;

  Member({required this.mucUid, required this.memberUid, required this.role});
}
