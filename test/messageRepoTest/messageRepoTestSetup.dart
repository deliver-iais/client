import 'dart:async';

import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';

class MockMessageDao extends Mock implements MessageDao {}

class MockRoomDao extends Mock implements RoomDao {}

class MockPendingMessageDao extends Mock implements PendingMessageDao {}

class MockAccountRepo extends Mock implements AccountRepo {}

class MockFileRepo extends Mock implements FileRepo {}

class MockMucRepo extends Mock implements MucRepo {}

class MockCoreServices extends Mock implements CoreServices {
  BehaviorSubject<ConnectionStatus> connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Disconnected);
}

class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T value;

  MockResponseFuture(this.value);

  Future<S> then<S>(FutureOr<S> onValue(T value), {Function onError}) =>
      Future.value(value).then(onValue, onError: onError);
}

class MockQueryServiceClient extends Mock implements QueryServiceClient {}

void messageRepoTestSetup() {
  GetIt.instance.reset();
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<MessageDao>(MockMessageDao());
  getIt.registerSingleton<RoomDao>(MockRoomDao());
  getIt.registerSingleton<PendingMessageDao>(MockPendingMessageDao());
  getIt.registerSingleton<AccountRepo>(MockAccountRepo());
  getIt.registerSingleton<FileRepo>(MockFileRepo());
  getIt.registerSingleton<MucRepo>(MockMucRepo());
  getIt.registerSingleton<CoreServices>(MockCoreServices());
  getIt.registerSingleton<QueryServiceClient>(MockQueryServiceClient());
}
