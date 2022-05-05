import 'package:collection/collection.dart';
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

  Member({
    required this.mucUid,
    required this.memberUid,
    this.role = MucRole.NONE,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Member &&
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
}
