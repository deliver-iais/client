import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'role.g.dart';

@HiveType(typeId: ROLE_TRACK_ID)
enum MucRole {
  @HiveField(0)
  NONE,

  @HiveField(1)
  MEMBER,

  @HiveField(2)
  ADMIN,

  @HiveField(3)
  OWNER,
}
