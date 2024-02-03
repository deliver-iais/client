
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'local_network_connections_hive.g.dart';

@HiveType(typeId: LOCCAL_NETWORK_CONNECTIONS_TRACK_ID)
class LocalNetworkConnectionsHive {
  @HiveField(0)
  String uid;

  @HiveField(1)
  int? lastUpdateTime;

  @HiveField(2)
  bool? backupLocalMessage;

  @HiveField(3)
  String ip;

  LocalNetworkConnectionsHive({
    required this.uid,
    this.lastUpdateTime = 0,
    this.backupLocalMessage = true,
    this.ip = "",
  });

  LocalNetworkConnectionsHive copyWith({
    String? uid,
    int? lastUpdateTime,
    bool? backupLocalMessage,
    String? ip,
  }) {
    return LocalNetworkConnectionsHive(
      uid: uid ?? this.uid,
      backupLocalMessage: backupLocalMessage ?? this.backupLocalMessage,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      ip: ip ?? this.ip,
    );
  }

  LocalNetworkConnections fromHive() => LocalNetworkConnections(
      uid: uid.asUid(),
      lastUpdateTime: lastUpdateTime ?? 0,
      backupLocalMessages: backupLocalMessage ?? true,
      ip: ip);
}

extension LocalNetworkConnectionsHiveMapper on LocalNetworkConnections {
  LocalNetworkConnectionsHive toHive() => LocalNetworkConnectionsHive(
        uid: uid.asString(),
        backupLocalMessage: backupLocalMessages,
        ip: ip,
        lastUpdateTime: lastUpdateTime,
      );
}
