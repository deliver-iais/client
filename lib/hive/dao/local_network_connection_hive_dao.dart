import 'dart:async';

import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/hive/local_network_connections_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive_flutter/adapters.dart';

class LocalNetworkConnectionDaoImpl extends LocalNetworkConnectionDao {
  Future<Box<LocalNetworkConnectionsHive>> _open() async {
    return Hive.openBox<LocalNetworkConnectionsHive>(
      "local-network-connections",
    );
  }

  @override
  Future<void> delete(Uid uid) async {
    try {
      final box = await _open();
      unawaited(box.delete(uid.asString()));
    } catch (_) {}
  }

  @override
  Future<void> deleteAll() async {
    try {
      final box = await _open();
      unawaited(box.clear());
    } catch (_) {}
  }

  @override
  Future<LocalNetworkConnections?> get(Uid uid) async {
    try {
      final box = await _open();
      return box.get(uid.asString())?.fromHive();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(LocalNetworkConnections localNetworkConnections) async {
    try {
      final box = await _open();
      return box.put(localNetworkConnections.uid.asString(),
          localNetworkConnections.toHive());
    } catch (_) {}
  }

  @override
  Stream<LocalNetworkConnections?> watch(Uid uid) async* {
    try {
      final box = await _open();
      yield box.get(uid.asString())?.fromHive();

      yield* box
          .watch(key: uid.asString())
          .map((event) => (event as LocalNetworkConnectionsHive).fromHive());
    } catch (_) {}
  }
}
