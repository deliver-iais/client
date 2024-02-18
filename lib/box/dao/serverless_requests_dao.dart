import 'dart:async';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/serverless_requests.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive/hive.dart';

class ServerLessRequestsDao {
  String _key() => "serverless_requests";

  String _genId(ServerLessRequest serverLessRequest) =>
      "${serverLessRequest.uid}_${serverLessRequest.time}";

  Future<BoxPlus<ServerLessRequest>> _openBox() async {
    try {
      DBManager.open(_key(), TableInfo.MY_SEEN_TABLE_NAME);
      return gen(Hive.openBox<ServerLessRequest>(_key()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_key());
      return gen(Hive.openBox<ServerLessRequest>(_key()));
    }
  }

  Future<void> save(ServerLessRequest serverLessRequest) async {
    try {
      final box = await _openBox();
      await box.put(
        _genId(serverLessRequest),
        serverLessRequest,
      );
    } catch (_) {}
  }

  Future<List<ServerLessRequest>> getUserRequests(Uid uid) async {
    try {
      final box = await _openBox();
      return box.values
          .where((element) => uid.isSameEntity(element.uid))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> remove(ServerLessRequest serverLessRequest) async {
    try {
      final box = await _openBox();
      unawaited(box.delete(_genId(serverLessRequest)));
    } catch (_) {}
  }
}
