import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import '../helper/test_helper.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<Logger>(returnNullOnMissingStub: true),
  MockSpec<MessageDao>(returnNullOnMissingStub: true),
  MockSpec<RoomDao>(returnNullOnMissingStub: true),
  MockSpec<RoomRepo>(returnNullOnMissingStub: true),
  MockSpec<AuthRepo>(returnNullOnMissingStub: true),
  MockSpec<FileRepo>(returnNullOnMissingStub: true),
  MockSpec<LiveLocationRepo>(returnNullOnMissingStub: true),
  MockSpec<SeenDao>(returnNullOnMissingStub: true),
  MockSpec<MucServices>(returnNullOnMissingStub: true),
  MockSpec<CoreServices>(returnNullOnMissingStub: true),
  MockSpec<QueryServiceClient>(returnNullOnMissingStub: true),
  // MockSpec<SharedDao>(returnNullOnMissingStub: true),
  MockSpec<AvatarRepo>(returnNullOnMissingStub: true),
  MockSpec<BlockDao>(returnNullOnMissingStub: true),
])
MockCoreServices getAndRegisterCoreServices() {
  _removeRegistrationIfExists<CoreServices>();
  final service = MockCoreServices();
  GetIt.I.registerSingleton<CoreServices>(service);
  return service;
}

MockLogger getAndRegisterLogger() {
  _removeRegistrationIfExists<Logger>();
  final service = MockLogger();
  GetIt.I.registerSingleton<Logger>(Logger());
  GetIt.I.registerSingleton<MockLogger>(service);
  return service;
}

MockMessageDao getAndRegisterMessageDao() {
  _removeRegistrationIfExists<MessageDao>();
  final service = MockMessageDao();
  GetIt.I.registerSingleton<MessageDao>(service);
  return service;
}

MockRoomDao getAndRegisterRoomDao() {
  _removeRegistrationIfExists<RoomDao>();
  final service = MockRoomDao();
  GetIt.I.registerSingleton<RoomDao>(service);
  return service;
}

MockRoomRepo getAndRegisterRoomRepo() {
  _removeRegistrationIfExists<RoomRepo>();
  final service = MockRoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  return service;
}

MockAuthRepo getAndRegisterAuthRepo() {
  _removeRegistrationIfExists<AuthRepo>();
  final service = MockAuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(service);
  return service;
}

MockFileRepo getAndRegisterFileRepo() {
  _removeRegistrationIfExists<FileRepo>();
  final service = MockFileRepo();
  GetIt.I.registerSingleton<FileRepo>(service);
  return service;
}
MockLiveLocationRepo getAndRegisterLiveLocationRepo() {
  _removeRegistrationIfExists<LiveLocationRepo>();
  final service = MockLiveLocationRepo();
  GetIt.I.registerSingleton<LiveLocationRepo>(service);
  return service;
}
MockSeenDao getAndRegisterSeenDao() {
  _removeRegistrationIfExists<SeenDao>();
  final service = MockSeenDao();
  GetIt.I.registerSingleton<SeenDao>(service);
  return service;
}

void registerServices() {
  getAndRegisterCoreServices();
  getAndRegisterLogger();
  getAndRegisterMessageDao();
  getAndRegisterRoomDao();
  getAndRegisterRoomRepo();
  getAndRegisterAuthRepo();
  getAndRegisterFileRepo();
  getAndRegisterLiveLocationRepo();
  getAndRegisterSeenDao();
}

void unregisterServices() {
  GetIt.I.unregister<CoreServices>();
  GetIt.I.unregister<Logger>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }
}
