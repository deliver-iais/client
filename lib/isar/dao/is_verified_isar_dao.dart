import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/is_verified_dao.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/is_verified.dart';
import 'package:deliver/isar/is_verified_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class IsVerifiedDaoImpl extends IsVerifiedDao {
  @override
  Future<IsVerified?> getIsVerified(Uid uid) async {
    final box = await _openIsVerifiedIsar();
    return (await box.isVerifiedIsars
            .filter()
            .uidEqualTo(uid.asString())
            .findFirst())
        ?.fromIsar();
  }

  @override
  Future<void> update(Uid uid, int expireTime) async {
    final lastUpdateTime = clock.now().millisecondsSinceEpoch;
    final box = await _openIsVerifiedIsar();
    unawaited(box.writeTxn(() async {
      await box.isVerifiedIsars.filter().uidEqualTo(uid.asString()).deleteAll();
      await box.isVerifiedIsars.put(
        IsVerifiedIsar(
          uid: uid.asString(),
          lastUpdate: lastUpdateTime,
          expireTime: expireTime,
        ),
      );
    }));
  }

  Future<Isar> _openIsVerifiedIsar() => IsarManager.open();
}
