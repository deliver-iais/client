import 'dart:async';

import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart' as seen_box;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import '../helper/test_helper.mocks.dart';
import '../repository/messageRepo_test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;

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

MockMessageDao getAndRegisterMessageDao(
    {Message? message, bool getError = false}) {
  _removeRegistrationIfExists<MessageDao>();
  final service = MockMessageDao();
  GetIt.I.registerSingleton<MessageDao>(service);
  message == null
      ? getError
          ? when(service.getMessage(testUid.asString(), 0))
              .thenThrow((realInvocation) => "error")
          : when(service.getMessage(testUid.asString(), 0))
              .thenAnswer((realInvocation) => Future.value(null))
      : when(service.getMessage(testUid.asString(), 0))
          .thenAnswer((realInvocation) => Future.value(message));
  return service;
}

MockRoomDao getAndRegisterRoomDao({List<Room>? rooms}) {
  _removeRegistrationIfExists<RoomDao>();
  final service = MockRoomDao();
  GetIt.I.registerSingleton<RoomDao>(service);
  when(service.getRoom(testUid.asString())).thenAnswer((realInvocation) =>
      Future.value(rooms?.first ?? Room(uid: testUid.asString())));
  rooms ??= [
    Room(
      uid: testUid.asString(),
    )
  ];
  when(service.getAllRooms())
      .thenAnswer((realInvocation) => Future.value(rooms));
  return service;
}

MockRoomRepo getAndRegisterRoomRepo() {
  _removeRegistrationIfExists<RoomRepo>();
  final service = MockRoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  return service;
}

MockAuthRepo getAndRegisterAuthRepo({bool isCurrentUser = false}) {
  _removeRegistrationIfExists<AuthRepo>();
  final service = MockAuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(service);
  when(service.isCurrentUser(testUid.asString())).thenReturn(isCurrentUser);
  when(service.currentUserUid).thenReturn(testUid);
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

MockSeenDao getAndRegisterSeenDao({int? messageId}) {
  _removeRegistrationIfExists<SeenDao>();
  final service = MockSeenDao();
  GetIt.I.registerSingleton<SeenDao>(service);
  when(service.getOthersSeen(testUid.asString())).thenAnswer((realInvocation) =>
      Future.value(
          seen_box.Seen(uid: testUid.asString(), messageId: messageId)));
  when(service.getMySeen(testUid.asString())).thenAnswer((realInvocation) =>
      Future.value(
          seen_box.Seen(uid: testUid.asString(), messageId: messageId)));
  return service;
}

MockMucServices getAndRegisterMucServices() {
  _removeRegistrationIfExists<MucServices>();
  final service = MockMucServices();
  GetIt.I.registerSingleton<MucServices>(service);
  return service;
}

MockQueryServiceClient getAndRegisterQueryServiceClient(
    {bool finished = true,
    PresenceType presenceType = PresenceType.ACTIVE,
    int? lastMessageId,
    int? lastUpdate,
    int fetchMessagesId = 0,
    String? fetchMessagesText,
    int? mentionIdList}) {
  _removeRegistrationIfExists<QueryServiceClient>();
  final service = MockQueryServiceClient();
  GetIt.I.registerSingleton<QueryServiceClient>(service);
  RoomMetadata roomMetadata = RoomMetadata(
      roomUid: testUid,
      lastMessageId: lastMessageId != null ? Int64(lastMessageId) : null,
      firstMessageId: null,
      lastCurrentUserSentMessageId:
          lastUpdate != null ? Int64(lastUpdate) : null,
      lastUpdate: null,
      presenceType: presenceType);
  Iterable<RoomMetadata>? roomsMeta = {roomMetadata};
  when(service.getAllUserRoomMeta(GetAllUserRoomMetaReq()
        ..pointer = 0
        ..limit = 10))
      .thenAnswer((realInvocation) {
    return MockResponseFuture<GetAllUserRoomMetaRes>(
        GetAllUserRoomMetaRes(roomsMeta: roomsMeta, finished: finished));
  });
  when(service.getUserRoomMeta(GetUserRoomMetaReq()..roomUid = testUid))
      .thenAnswer((realInvocation) {
    return MockResponseFuture<GetUserRoomMetaRes>(
        GetUserRoomMetaRes(roomMeta: roomMetadata));
  });
  when(service.fetchCurrentUserSeenData(
          FetchCurrentUserSeenDataReq()..roomUid = testUid))
      .thenAnswer((realInvocation) {
    return MockResponseFuture<FetchCurrentUserSeenDataRes>(
        FetchCurrentUserSeenDataRes(
            seen: seen_pb.Seen(from: testUid, to: testUid)));
  });
  when(service.fetchLastOtherUserSeenData(
          FetchLastOtherUserSeenDataReq()..roomUid = testUid))
      .thenAnswer((realInvocation) {
    return MockResponseFuture<FetchLastOtherUserSeenDataRes>(
        FetchLastOtherUserSeenDataRes(
            seen: seen_pb.Seen(from: testUid, to: testUid)));
  });
  when(service.countIsHiddenMessages(CountIsHiddenMessagesReq()
        ..roomUid = testUid
        ..messageId = Int64(0 + 1)))
      .thenAnswer((realInvocation) =>
          MockResponseFuture<CountIsHiddenMessagesRes>(
              CountIsHiddenMessagesRes(count: 0)));

  when(service.fetchMessages(
          FetchMessagesReq()
            ..roomUid = testUid
            ..pointer = Int64(0)
            ..type = FetchMessagesReq_Type.BACKWARD_FETCH
            ..limit = 0,
          options: CallOptions(timeout: const Duration(seconds: 3))))
      .thenAnswer((realInvocation) =>
          MockResponseFuture<FetchMessagesRes>(FetchMessagesRes(messages: {
            message_pb.Message(
                packetId: "",
                time: Int64(0),
                id: Int64(fetchMessagesId),
                to: testUid,
                from: testUid,
                text: fetchMessagesText != null
                    ? message_pb.Text(text: fetchMessagesText)
                    : null,
                edited: false,
                replyToId: Int64(0),
                forwardFrom: testUid,
                encrypted: false)
          })));
  when(service.fetchMentionList(FetchMentionListReq()
        ..group = testUid
        ..afterId = Int64.parseInt("0")))
      .thenAnswer((realInvocation) => MockResponseFuture<FetchMentionListRes>(
          FetchMentionListRes(
              idList: mentionIdList != null ? [Int64(mentionIdList)] : [])));
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
