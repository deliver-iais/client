import 'dart:async';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/custom_notication_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart' as seen_box;
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import '../constants/constants.dart';
import '../helper/test_helper.mocks.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver/box/contact.dart' as contact_pb;

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
  MockSpec<FireBaseServices>(returnNullOnMissingStub: true),
  MockSpec<FileRepo>(returnNullOnMissingStub: true),
  MockSpec<LiveLocationRepo>(returnNullOnMissingStub: true),
  MockSpec<SeenDao>(returnNullOnMissingStub: true),
  MockSpec<MucServices>(returnNullOnMissingStub: true),
  MockSpec<CoreServices>(returnNullOnMissingStub: true),
  MockSpec<QueryServiceClient>(returnNullOnMissingStub: true),
  MockSpec<SharedDao>(returnNullOnMissingStub: true),
  MockSpec<AvatarRepo>(returnNullOnMissingStub: true),
  MockSpec<BlockDao>(returnNullOnMissingStub: true),
  MockSpec<I18N>(returnNullOnMissingStub: true),
  MockSpec<MuteDao>(returnNullOnMissingStub: true),
  MockSpec<UidIdNameDao>(returnNullOnMissingStub: true),
  MockSpec<ContactRepo>(returnNullOnMissingStub: true),
  MockSpec<AccountRepo>(returnNullOnMissingStub: true),
  MockSpec<MucRepo>(returnNullOnMissingStub: true),
  MockSpec<BotRepo>(returnNullOnMissingStub: true),
  MockSpec<CustomNotificatonDao>(returnNullOnMissingStub: true),
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

MockI18N getAndRegisterI18N() {
  _removeRegistrationIfExists<I18N>();
  final service = MockI18N();
  GetIt.I.registerSingleton<I18N>(service);
  when(service.get("you")).thenReturn("you");
  return service;
}

MockMuteDao getAndRegisterMuteDao() {
  _removeRegistrationIfExists<MuteDao>();
  final service = MockMuteDao();
  GetIt.I.registerSingleton<MuteDao>(service);
  return service;
}

MockUidIdNameDao getAndRegisterUidIdNameDao(
    {bool getByUidHasData = false, bool getUidByIdHasData = false}) {
  _removeRegistrationIfExists<UidIdNameDao>();
  final service = MockUidIdNameDao();
  GetIt.I.registerSingleton<UidIdNameDao>(service);
  when(service.getByUid(any)).thenAnswer((realInvocation) => Future.value(
      getByUidHasData
          ? UidIdName(uid: testUid.asString(), name: "test", id: "test")
          : null));
  when(service.search("test")).thenAnswer((realInvocation) =>
      Future.value([UidIdName(uid: testUid.asString(), name: "test")]));
  when(service.getUidById("test")).thenAnswer((realInvocation) =>
      Future.value(getUidByIdHasData ? testUid.asString() : null));
  return service;
}

MockContactRepo getAndRegisterContactRepo(
    {bool getContactHasData = false, String? getContactFromServerData}) {
  _removeRegistrationIfExists<ContactRepo>();
  final service = MockContactRepo();
  GetIt.I.registerSingleton<ContactRepo>(service);
  when(service.getContact(testUid)).thenAnswer((realInvocation) => Future.value(
      getContactHasData
          ? contact_pb.Contact(
              uid: testUid.asString(),
              firstName: "test",
              lastName: "test",
              countryCode: "098",
              nationalNumber: "098")
          : null));
  when(service.getContactFromServer(testUid))
      .thenAnswer((realInvocation) => Future.value(getContactFromServerData));
  return service;
}

MockAccountRepo getAndRegisterAccountRepo() {
  _removeRegistrationIfExists<AccountRepo>();
  final service = MockAccountRepo();
  GetIt.I.registerSingleton<AccountRepo>(service);
  when(service.getName()).thenAnswer((realInvocation) => Future.value("test"));
  return service;
}

MockMucRepo getAndRegisterMucRepo({Muc? fetchMucInfo}) {
  _removeRegistrationIfExists<MucRepo>();
  final service = MockMucRepo();
  GetIt.I.registerSingleton<MucRepo>(service);
  when(service.fetchMucInfo(any))
      .thenAnswer((realInvocation) => Future.value(fetchMucInfo));
  return service;
}

MockBotRepo getAndRegisterBotRepo({BotInfo? botInfo}) {
  _removeRegistrationIfExists<BotRepo>();
  final service = MockBotRepo();
  GetIt.I.registerSingleton<BotRepo>(service);
  when(service.getBotInfo(botUid))
      .thenAnswer((realInvocation) => Future.value(botInfo));
  return service;
}

MockCustomNotificatonDao getAndRegisterCustomNotificatonDao() {
  _removeRegistrationIfExists<CustomNotificatonDao>();
  final service = MockCustomNotificatonDao();
  GetIt.I.registerSingleton<CustomNotificatonDao>(service);
  when(service.isHaveCustomNotif(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value(false));
  when(service.getCustomNotif(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value("/test"));
  return service;
}

MockMessageDao getAndRegisterMessageDao(
    {Message? message,
    bool getError = false,
    PendingMessage? allPendingMessage,
    PendingMessage? pendingMessage}) {
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
  when(service.getMessagePage(testUid.asString(), 0)).thenAnswer(
      (realInvocation) => Future.value([testMessage.copyWith(id: 0)]));
  when(service.getAllPendingMessages()).thenAnswer((realInvocation) =>
      allPendingMessage != null
          ? Future.value([allPendingMessage])
          : Future.value([]));
  when(service.getPendingMessage("")).thenAnswer((realInvocation) =>
      pendingMessage != null ? Future.value(pendingMessage) : Future.value());
  when(service.watchPendingMessage(""))
      .thenAnswer((realInvocation) => Stream.value(testPendingMessage));
  when(service.watchPendingMessages(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value([testPendingMessage]));
  when(service.getPendingMessages(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value([testPendingMessage]));
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
  when(service.getRoom(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value(rooms?.first));
  when(service.watchAllRooms())
      .thenAnswer((realInvocation) => Stream.value([testRoom]));
  when(service.watchRoom(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value(testRoom));
  when(service.getAllGroups()).thenAnswer((realInvocation) => Future.value([testRoom]));
  return service;
}

MockRoomRepo getAndRegisterRoomRepo(
    {Room? room, bool getRoomGetError = false}) {
  _removeRegistrationIfExists<RoomRepo>();
  final service = MockRoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  getRoomGetError
      ? when(service.getRoom(testUid.asString()))
          .thenThrow((realInvocation) => Future.value())
      : when(service.getRoom(testUid.asString())).thenAnswer((realInvocation) =>
          Future.value(room ?? Room(uid: testUid.asString())));
  return service;
}

RoomRepo getAndRegisterRealRoomRepo() {
  _removeRegistrationIfExists<RoomRepo>();
  final service = RoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  return service;
}

MockAuthRepo getAndRegisterAuthRepo({bool isCurrentUser = false}) {
  _removeRegistrationIfExists<AuthRepo>();
  final service = MockAuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(service);
  when(service.isCurrentUser(any)).thenReturn(isCurrentUser);
  when(service.currentUserUid).thenReturn(testUid);
  return service;
}

MockFileRepo getAndRegisterFileRepo({file_pb.File? fileInfo}) {
  _removeRegistrationIfExists<FileRepo>();
  final service = MockFileRepo();
  GetIt.I.registerSingleton<FileRepo>(service);
  when(service.uploadClonedFile("946672200000000", "test",
          sendActivity: anyNamed("sendActivity")))
      .thenAnswer((realInvocation) => Future.value(fileInfo));
  when(service.uploadClonedFile(
    "946672200000",
    "test",
  )).thenAnswer((realInvocation) => Future.value(fileInfo));

  return service;
}

MockLiveLocationRepo getAndRegisterLiveLocationRepo() {
  _removeRegistrationIfExists<LiveLocationRepo>();
  final service = MockLiveLocationRepo();
  GetIt.I.registerSingleton<LiveLocationRepo>(service);
  when(service.createLiveLocation(testUid, 0)).thenAnswer((realInvocation) =>
      MockResponseFuture<CreateLiveLocationRes>(
          CreateLiveLocationRes(uuid: testUid.asString())));
  return service;
}

MockSeenDao getAndRegisterSeenDao({int messageId = 0}) {
  _removeRegistrationIfExists<SeenDao>();
  final service = MockSeenDao();
  GetIt.I.registerSingleton<SeenDao>(service);
  when(service.getOthersSeen(testUid.asString())).thenAnswer((realInvocation) =>
      Future.value(
          seen_box.Seen(uid: testUid.asString(), messageId: messageId)));
  when(service.getMySeen(testUid.asString())).thenAnswer((realInvocation) =>
      Future.value(
          seen_box.Seen(uid: testUid.asString(), messageId: messageId)));
  when(service.watchMySeen(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value(testSeen));
  return service;
}

MockMucServices getAndRegisterMucServices({bool pinMessageGetError = false}) {
  _removeRegistrationIfExists<MucServices>();
  final service = MockMucServices();
  GetIt.I.registerSingleton<MucServices>(service);
  pinMessageGetError
      ? when(service.pinMessage(testMessage))
          .thenThrow((realInvocation) => Future.value())
      : when(service.pinMessage(testMessage))
          .thenAnswer((realInvocation) => Future.value(true));
  pinMessageGetError
      ? when(service.unpinMessage(testMessage))
          .thenThrow((realInvocation) => Future.value())
      : when(service.unpinMessage(testMessage))
          .thenAnswer((realInvocation) => Future.value(true));
  return service;
}

MockQueryServiceClient getAndRegisterQueryServiceClient(
    {bool finished = true,
    PresenceType presenceType = PresenceType.ACTIVE,
    int? lastMessageId,
    int? lastUpdate,
    bool countIsHiddenMessagesGetError = false,
    int fetchMessagesId = 0,
    String? fetchMessagesText,
    int fetchMessagesLimit = 0,
    bool fetchMessagesHasOptions = true,
    FetchMessagesReq_Type fetchMessagesType =
        FetchMessagesReq_Type.BACKWARD_FETCH,
    PersistentEvent? fetchMessagesPersistEvent,
    int? mentionIdList,
    int updateMessageId = 0,
    bool updateMessageGetError = false,
    bool removePrivateRoomGetError = false,
    bool getIdByUidGetError = false,
    String? getIdByUidData,
    message_pb.MessageByClient? updatedMessageFile}) {
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
  countIsHiddenMessagesGetError
      ? when(service.countIsHiddenMessages(CountIsHiddenMessagesReq()
            ..roomUid = testUid
            ..messageId = Int64(0 + 1)))
          .thenThrow((realInvocation) => Future.value())
      : when(service.countIsHiddenMessages(CountIsHiddenMessagesReq()
            ..roomUid = testUid
            ..messageId = Int64(0 + 1)))
          .thenAnswer((realInvocation) =>
              MockResponseFuture<CountIsHiddenMessagesRes>(
                  CountIsHiddenMessagesRes(count: 0)));

  when(service.fetchMessages(
          FetchMessagesReq()
            ..roomUid = testUid
            ..pointer = Int64(0)
            ..type = fetchMessagesType
            ..limit = fetchMessagesLimit,
          options: fetchMessagesHasOptions
              ? CallOptions(timeout: const Duration(seconds: 3))
              : null))
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
                persistEvent: fetchMessagesPersistEvent,
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
  when(service.deleteMessage(DeleteMessageReq()
        ..messageId = Int64(0)
        ..roomUid = testUid))
      .thenAnswer((realInvocation) =>
          MockResponseFuture<DeleteMessageRes>(DeleteMessageRes()));
  var updatedMessage = message_pb.MessageByClient()
    ..to = testMessage.to.asUid()
    ..replyToId = Int64(testMessage.replyToId)
    ..text = message_pb.Text(text: "test");
  updateMessageGetError
      ? when(service.updateMessage(UpdateMessageReq()
            ..message = updatedMessageFile ?? updatedMessage
            ..messageId = Int64(updateMessageId)))
          .thenThrow((realInvocation) =>
              MockResponseFuture<UpdateMessageRes>(UpdateMessageRes()))
      : when(service.updateMessage(UpdateMessageReq()
            ..message = updatedMessageFile ?? updatedMessage
            ..messageId = Int64(updateMessageId)))
          .thenAnswer((realInvocation) =>
              MockResponseFuture<UpdateMessageRes>(UpdateMessageRes()));
  when(service.getBlockedList(GetBlockedListReq())).thenAnswer(
      (realInvocation) => MockResponseFuture<GetBlockedListRes>(
          GetBlockedListRes(uidList: [testUid])));
  removePrivateRoomGetError
      ? when(service
              .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid))
          .thenThrow((realInvocation) =>
              MockResponseFuture<RemovePrivateRoomRes>(RemovePrivateRoomRes()))
      : when(service
              .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid))
          .thenAnswer((realInvocation) =>
              MockResponseFuture<RemovePrivateRoomRes>(RemovePrivateRoomRes()));
  getIdByUidGetError
      ? when(service.getIdByUid(GetIdByUidReq()..uid = testUid)).thenThrow(
          (realInvocation) =>
              MockResponseFuture<GetIdByUidRes>(GetIdByUidRes()))
      : when(service.getIdByUid(GetIdByUidReq()..uid = testUid)).thenAnswer(
          (realInvocation) => MockResponseFuture<GetIdByUidRes>(
              GetIdByUidRes(id: getIdByUidData)));
  getIdByUidGetError
      ? when(service.getIdByUid(GetIdByUidReq()..uid = groupUid)).thenThrow(
          (realInvocation) =>
              MockResponseFuture<GetIdByUidRes>(GetIdByUidRes()))
      : when(service.getIdByUid(GetIdByUidReq()..uid = groupUid)).thenAnswer(
          (realInvocation) => MockResponseFuture<GetIdByUidRes>(
              GetIdByUidRes(id: getIdByUidData)));
  when(service.block(BlockReq()..uid = testUid))
      .thenAnswer((realInvocation) => MockResponseFuture<BlockRes>(BlockRes()));
  when(service.unblock(UnblockReq()..uid = testUid)).thenAnswer(
      (realInvocation) => MockResponseFuture<UnblockRes>(UnblockRes()));
  when(service.getUidById(GetUidByIdReq()..id = "test")).thenAnswer(
      (realInvocation) =>
          MockResponseFuture<GetUidByIdRes>(GetUidByIdRes(uid: testUid)));
  when(service.report(ReportReq()..uid = testUid)).thenAnswer(
      (realInvocation) => MockResponseFuture<ReportRes>(ReportRes()));
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
  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
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
  when(service.isBlocked(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value(false));
  when(service.watchIsBlocked(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value(false));
  return service;
}

MockFireBaseServices getAndRegisterFireBaseServices() {
  _removeRegistrationIfExists<MockFireBaseServices>();
  final service = MockFireBaseServices();
  GetIt.I.registerSingleton<FireBaseServices>(service);
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
  getAndRegisterFireBaseServices();
  getAndRegisterI18N();
  getAndRegisterMuteDao();
  getAndRegisterUidIdNameDao();
  getAndRegisterContactRepo();
  getAndRegisterAccountRepo();
  getAndRegisterMucRepo();
  getAndRegisterBotRepo();
  getAndRegisterCustomNotificatonDao();
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
  GetIt.I.unregister<FireBaseServices>();
  GetIt.I.unregister<I18N>();
  GetIt.I.unregister<MuteDao>();
  GetIt.I.unregister<ContactRepo>();
  GetIt.I.unregister<AccountRepo>();
  GetIt.I.unregister<MucRepo>();
  GetIt.I.unregister<BotRepo>();
  GetIt.I.unregister<CustomNotificatonDao>();
}

void _removeRegistrationIfExists<T extends Object>() {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }
}
