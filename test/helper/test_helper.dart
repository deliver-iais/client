import 'package:audioplayers/audioplayers.dart';
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
  GetIt.I.registerSingleton<Logger>(service);
  return service;
}

void registerServices() {
  getAndRegisterCoreServices();
  getAndRegisterLogger();
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
