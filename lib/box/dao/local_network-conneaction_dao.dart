import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class LocalNetworkConnectionDao {
  Future<void> save(LocalNetworkConnections localNetworkConnections);

  Future<void> delete(Uid uid);

  Future<LocalNetworkConnections?> get(Uid uid);

  Stream<LocalNetworkConnections?> watch(Uid uid);

  Future<void> deleteAll();
}
