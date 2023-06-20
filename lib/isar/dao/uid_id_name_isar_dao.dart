import 'package:clock/clock.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/uid_id_name_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class UidIdNameDaoImpl extends UidIdNameDao {
  @override
  Future<UidIdName?> getByUid(Uid uid) async {
    final box = await _openIsar();
    return (await box.uidIdNameIsars.get(fastHash(uid.asString())))?.fromIsar();
  }

  @override
  Future<String?> getUidById(String id) async {
    final box = await _openIsar();
    return box.uidIdNameIsars.filter().idEqualTo(id).findFirstSync()?.uid;
  }

  @override
  Future<List<UidIdName>> search(String term) async {
    final box = await _openIsar();
    return box.uidIdNameIsars
        .filter()
        .nameContains(term)
        .or()
        .idContains(term)
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<void> update(
    Uid uid, {
    String? id,
    String? name,
    String? realName,
  }) async {
    final lastUpdateTime = clock.now().millisecondsSinceEpoch;
    final box = await _openIsar();
    box.writeTxnSync(() {
      final uidName = box.uidIdNameIsars
              .filter()
              .uidEqualTo(uid.asString())
              .findFirstSync() ??
          UidIdNameIsar(uid: uid.asString());
      box.uidIdNameIsars.putSync(
        UidIdNameIsar(
          uid: uid.asString(),
          realName: realName ?? uidName.realName,
          name: name ?? uidName.name,
          id: id ?? uidName.id,
          lastUpdateTime: lastUpdateTime,
        ),
      );
    });
  }

  @override
  Stream<String?> watchIdByUid(Uid uid) async* {
    final box = await _openIsar();

    final query =
        box.uidIdNameIsars.filter().uidEqualTo(uid.asString()).build();
    yield query.findFirstSync()?.fromIsar().id;

    yield* query.watch().map((event) => event.firstOrNull?.fromIsar().id);
  }

  Future<Isar> _openIsar() => IsarManager.open();
}
