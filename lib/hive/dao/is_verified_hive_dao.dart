import 'package:clock/clock.dart';
import 'package:deliver/box/dao/is_verified_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/is_verified.dart';
import 'package:deliver/hive/is_verified_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';

class IsVerifiedDaoImpl extends IsVerifiedDao {
  @override
  Future<IsVerified?> getIsVerified(Uid uid) async {
    final box = await _open();
    return box.get(uid)?.fromHive();
  }

  @override
  Future<void> update(Uid uid, int expireTime) async {
    final lastUpdateTime = clock.now().millisecondsSinceEpoch;
    final box = await _open();
    await box.put(
      uid.asString,
      IsVerifiedHive(
        uid: uid.asString(),
        lastUpdate: lastUpdateTime,
        expireTime: expireTime,
      ),
    );
  }

  String _key() => "is_verified";

  Future<BoxPlus<IsVerifiedHive>> _open() {
    DBManager.open(_key(), TableInfo.IS_VERIFIED_TABLE_NAME);
    return gen(Hive.openBox<IsVerifiedHive>(_key()));
  }
}
