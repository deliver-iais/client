import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';
import 'package:deliver/isar/helpers.dart';

part 'local_network_connections_isar.g.dart';

@collection
class LocalNetworkConnectionsIsar {
  Id get id => fastHash(uid);

  String uid;

  String ip;

  int lastUpdateTime;

  LocalNetworkConnectionsIsar({
    required this.uid,
    required this.ip,
    required this.lastUpdateTime,
  });

  LocalNetworkConnections fromIsar() => LocalNetworkConnections(
        uid: uid.asUid(),
        ip: ip,
        lastUpdateTime: lastUpdateTime,
      );
}

extension LocalNetworkConnectionsIsarMapper on LocalNetworkConnections {
  LocalNetworkConnectionsIsar toIsar() => LocalNetworkConnectionsIsar(
        uid: uid.asString(),
        ip: ip,
        lastUpdateTime: lastUpdateTime,
      );
}
