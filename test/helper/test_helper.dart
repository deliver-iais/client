import 'dart:async';

import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import '../helper/test_helper.mocks.dart';

class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T value;

  MockResponseFuture(this.value);

  @override
  Future<S> then<S>(FutureOr<S> Function(T value) onValue,
          {Function? onError}) =>
      Future.value(value).then(onValue, onError: onError);
}

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
  MockSpec<SharedDao>(returnNullOnMissingStub: true),
  MockSpec<AvatarRepo>(returnNullOnMissingStub: true),
  MockSpec<BlockDao>(returnNullOnMissingStub: true),
])
MockCoreServices getAndRegisterCoreServices(
    {ConnectionStatus connectionStatus = ConnectionStatus.Connecting}) {
  _removeRegistrationIfExists<CoreServices>();
  final service = MockCoreServices();
  GetIt.I.registerSingleton<CoreServices>(service);
  BehaviorSubject<ConnectionStatus> _connectionStatus =
      BehaviorSubject.seeded(ConnectionStatus.Connecting);
  _connectionStatus.add(connectionStatus);
  when(service.connectionStatus)
      .thenAnswer((realInvocation) => _connectionStatus);
  return service;
}

MockLogger getAndRegisterLogger() {
  _removeRegistrationIfExists<Logger>();
  final service = MockLogger();
  GetIt.I.registerSingleton<Logger>(service);
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
  when(service.getRoom("0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd")).thenAnswer(
      (realInvocation) =>
          Future.value(Room(uid: " 0:3049987b-e15d-4288-97cd-42dbc6d73abd")));
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

MockMucServices getAndRegisterMucServices() {
  _removeRegistrationIfExists<MucServices>();
  final service = MockMucServices();
  GetIt.I.registerSingleton<MucServices>(service);
  return service;
}

MockQueryServiceClient getAndRegisterQueryServiceClient() {
  _removeRegistrationIfExists<QueryServiceClient>();
  final service = MockQueryServiceClient();
  GetIt.I.registerSingleton<QueryServiceClient>(service);
  Iterable<RoomMetadata>? roomsMeta = {
    RoomMetadata(
        roomUid: Uid(
            sessionId: "ad619345-cfbb-43f9-9539-be00c8c5b718",
            category: Categories.USER,
            node: 'b89fa74c-a583-4d64-aa7d-56ab8e37edcd'),
        lastMessageId: null,
        firstMessageId: null,
        lastCurrentUserSentMessageId: null,
        lastUpdate: null,
        presenceType: PresenceType.ACTIVE)
  };
  when(service.getAllUserRoomMeta(GetAllUserRoomMetaReq()
        ..pointer = 0
        ..limit = 10))
      .thenAnswer((realInvocation) {
    return MockResponseFuture<GetAllUserRoomMetaRes>(
        GetAllUserRoomMetaRes(roomsMeta: roomsMeta, finished: true));
  });
  return service;
}

MockSharedDao getAndRegisterSharedDao() {
  _removeRegistrationIfExists<SharedDao>();
  final service = MockSharedDao();
  GetIt.I.registerSingleton<SharedDao>(service);
  when(service.get(SHARED_DAO_FETCH_ALL_ROOM))
      .thenAnswer((realInvocation) => Future.value(""));
  return service;
}

Future<MessageRepo> getAndRegisterMessageRepo() async {
  _removeRegistrationIfExists<MessageRepo>();
  GetIt.I.registerSingleton<MessageRepo>(await MessageRepo());
  MessageRepo service = GetIt.I.get<MessageRepo>();
  return service;
}

MockAvatarRepo getAndRegisterAvatarRepo() {
  _removeRegistrationIfExists<AvatarRepo>();
  final service = MockAvatarRepo();
  GetIt.I.registerSingleton<AvatarRepo>(service);
  return service;
}

MockBlockDao getAndRegisterBlockDao() {
  _removeRegistrationIfExists<BlockDao>();
  final service = MockBlockDao();
  GetIt.I.registerSingleton<BlockDao>(service);
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
  getAndRegisterMucServices();
  getAndRegisterQueryServiceClient();
  getAndRegisterSharedDao();
  getAndRegisterAvatarRepo();
  getAndRegisterBlockDao();
}

void unregisterServices() {
  GetIt.I.unregister<CoreServices>();
  GetIt.I.unregister<Logger>();
  GetIt.I.unregister<MessageDao>();
  GetIt.I.unregister<RoomDao>();
  GetIt.I.unregister<AuthRepo>();
  GetIt.I.unregister<FileRepo>();
  GetIt.I.unregister<LiveLocationRepo>();
  GetIt.I.unregister<SeenDao>();
  GetIt.I.unregister<MucServices>();
  GetIt.I.unregister<QueryServiceClient>();
  GetIt.I.unregister<SharedDao>();
  GetIt.I.unregister<AvatarRepo>();
  GetIt.I.unregister<BlockDao>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }
}
