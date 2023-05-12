import 'package:deliver/box/is_verified.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';
part 'is_verified_isar.g.dart';
@collection
class IsVerifiedIsar {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  final String uid;

  int lastUpdate;

  int expireTime;

  IsVerifiedIsar({
    required this.uid,
    required this.lastUpdate,
    required this.expireTime,
  });

  IsVerified fromIsar() => IsVerified(
        uid: uid.asUid(),
        expireTime: expireTime,
        lastUpdate: lastUpdate,
      );
}

extension IsVerifiedIsarMapper on IsVerified {
  IsVerifiedIsar toIsar() => IsVerifiedIsar(
        uid: uid.asString(),
        expireTime: expireTime,
        lastUpdate: lastUpdate,
      );
}
