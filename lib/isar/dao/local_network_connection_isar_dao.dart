import 'dart:async';

import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/local_network_connections_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class LocalNetworkConnectionDaoImpl extends LocalNetworkConnectionDao {
  Future<Isar> _openIsar() => IsarManager.open();

  @override
  Future<void> delete(Uid uid) async {
    try {
      final box = await _openIsar();
      box.writeTxnSync(
        () => box.localNetworkConnectionsIsars
            .deleteSync(fastHash(uid.asString())),
      );
    } catch (_) {}
  }

  @override
  Future<LocalNetworkConnections?> get(Uid uid) async {
    try {
      final box = await _openIsar();
      return (await box.localNetworkConnectionsIsars
              .get(fastHash(uid.asString())))
          ?.fromIsar();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(LocalNetworkConnections localNetworkConnections) async {
    try {
      final box = await _openIsar();
      box.writeTxnSync(() {
        box.localNetworkConnectionsIsars
            .putSync(localNetworkConnections.toIsar());
      });
    } catch (_) {}
  }

  @override
  Stream<LocalNetworkConnections?> watch(Uid uid) async* {
    try {
      final box = await _openIsar();
      final query = box.localNetworkConnectionsIsars
          .filter()
          .uidEqualTo(uid.asString())
          .build();

      yield query.findFirstSync()?.fromIsar();

      yield* query
          .watch()
          .where((event) => event.isNotEmpty)
          .map((event) => event.map((e) => e.fromIsar()).first);
    } catch (_) {
      print(_);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final box = await _openIsar();
      await box.writeTxn(() => box.localNetworkConnectionsIsars.clear());
    } catch (_) {
      print(_.toString());
    }
  }

  @override
  Stream<void> watchAll() async* {
    try {
      final box = await _openIsar();
      yield* box.localNetworkConnectionsIsars.watchLazy();
    } catch (_) {}
  }
}
