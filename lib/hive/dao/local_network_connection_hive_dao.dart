import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

class LocalNetworkConnectionDaoImpl extends LocalNetworkConnectionDao{
  @override
  Future<void> delete(Uid uid) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<LocalNetworkConnections?> get(Uid uid) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<void> save(LocalNetworkConnections localNetworkConnections) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Stream<LocalNetworkConnections?> watch(Uid uid) {
    // TODO: implement watch
    throw UnimplementedError();
  }

  @override
  Stream<void> watchAll() {
    // TODO: implement watchAll
    throw UnimplementedError();
  }
  
}