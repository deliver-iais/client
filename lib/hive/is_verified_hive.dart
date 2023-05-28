

import 'package:deliver/box/is_verified.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'is_verified_hive.g.dart';

@HiveType(typeId: IS_VERIFIED_TRACK_ID)
class IsVerifiedHive {
  @HiveField(0)
  String uid;

  @HiveField(1)
  int lastUpdate;

  @HiveField(2)
  int expireTime;

  IsVerifiedHive({
    required this.uid,
    required this.lastUpdate,
    required this.expireTime,
  });

  IsVerifiedHive copyWith({
    String? sizeType,
    required String uuid,
    String? name,
    String? path,
  }) =>
      IsVerifiedHive(
        uid: uid,
        lastUpdate: lastUpdate,
        expireTime: expireTime,
      );

  IsVerified fromHive() => IsVerified(
        uid: uid.asUid(),
        expireTime: expireTime,
        lastUpdate: lastUpdate,
      );
}

extension IsVerifiedHiveMapper on IsVerified {
  IsVerifiedHive toHive() => IsVerifiedHive(
        uid: uid.asString(),
        expireTime: expireTime,
        lastUpdate: lastUpdate,
      );
}
