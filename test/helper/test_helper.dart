import 'dart:async';
import 'dart:ui';

import 'package:deliver/box/account.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/contact.dart' as contact_pb;
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/custom_notification_dao.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/meta_count_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart' as seen_box;
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/meta.pb.dart' as meta_pb;
import 'package:deliver_public_protocol/pub/v1/models/meta.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import 'mock_services_discovery_repo.dart';
import 'test_helper.mocks.dart';

class MockResponseFuture<T> extends Mock implements ResponseFuture<T> {
  final T value;

  MockResponseFuture(this.value);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(T value) onValue, {
    Function? onError,
  }) =>
      Future.value(value).then(onValue, onError: onError);
}

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<AnalyticsRepo>(),
    MockSpec<Logger>(),
    MockSpec<MessageDao>(),
    MockSpec<RoomDao>(),
    MockSpec<RoomRepo>(),
    MockSpec<AuthRepo>(),
    MockSpec<FireBaseServices>(),
    MockSpec<FileRepo>(),
    MockSpec<LiveLocationRepo>(),
    MockSpec<SeenDao>(),
    MockSpec<MucServices>(),
    MockSpec<DataStreamServices>(),
    MockSpec<CoreServices>(),
    MockSpec<QueryServiceClient>(),
    MockSpec<AuthServiceClient>(),
    MockSpec<SharedDao>(),
    MockSpec<AvatarRepo>(),
    MockSpec<BlockDao>(),
    MockSpec<I18N>(),
    MockSpec<MuteDao>(),
    MockSpec<UidIdNameDao>(),
    MockSpec<ContactRepo>(),
    MockSpec<AccountRepo>(),
    MockSpec<MucRepo>(),
    MockSpec<BotRepo>(),
    MockSpec<CustomNotificationDao>(),
    MockSpec<MetaDao>(),
    MockSpec<MetaRepo>(),
    MockSpec<MetaCountDao>(),
    MockSpec<CallService>(),
    MockSpec<NotificationServices>(),
    MockSpec<LastActivityDao>(),
    MockSpec<MucDao>(),
    MockSpec<Settings>(),
    MockSpec<UrlHandlerService>(),
    MockSpec<RoutingService>(),
    MockSpec<CallRepo>(),
    MockSpec<AppLifecycleService>(),
    MockSpec<AnalyticsService>(),
    MockSpec<AudioService>(),
    MockSpec<FileService>(),
    MockSpec<SharedPreferences>()
  ],
)
MockCoreServices getAndRegisterCoreServices({
  ConnectionStatus connectionStatus = ConnectionStatus.Disconnected,
}) {
  _removeRegistrationIfExists<CoreServices>();
  final service = MockCoreServices();
  GetIt.I.registerSingleton<CoreServices>(service);
  final cs =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.Connecting)
        ..add(connectionStatus);
  when(service.connectionStatus).thenAnswer((realInvocation) => cs);
  return service;
}

MockRoutingService getAndRegisterRoutingServices() {
  _removeRegistrationIfExists<RoutingService>();
  final service = MockRoutingService();
  GetIt.I.registerSingleton<RoutingService>(service);
  return service;
}

MockAudioService getAndRegisterAudioServices() {
  _removeRegistrationIfExists<AudioService>();
  final service = MockAudioService();
  GetIt.I.registerSingleton<AudioService>(service);
  return service;
}

MockAnalyticsService getAndRegisterAnalyticsService() {
  _removeRegistrationIfExists<AnalyticsService>();
  final service = MockAnalyticsService();
  GetIt.I.registerSingleton<AnalyticsService>(service);
  return service;
}

MockFileService getAndRegisterFileService() {
  _removeRegistrationIfExists<FileService>();
  final service = MockFileService();
  GetIt.I.registerSingleton<FileService>(service);
  when(service.compressFile(any))
      .thenAnswer((realInvocation) => Future.value(model.File("test", "test")));
  return service;
}

void setInitializeValueForSharedPreferences() {
  SharedPreferences.setMockInitialValues({}); //set values here
}

MockSettings getAndRegisterUxService({
  bool isAllNotificationDisabled = false,
}) {
  _removeRegistrationIfExists<Settings>();
  final service = MockSettings();
  GetIt.I.registerSingleton<Settings>(service);
  when(service.isAllNotificationDisabled.value)
      .thenAnswer((realInvocation) => isAllNotificationDisabled);
  return service;
}

MockDataStreamServices getAndRegisterDataStreamServices() {
  _removeRegistrationIfExists<DataStreamServices>();
  final service = MockDataStreamServices();
  GetIt.I.registerSingleton<DataStreamServices>(service);
  when(service.fetchLastNotHiddenMessage(testUid, 0, 0))
      .thenAnswer((realInvocation) => Future.value(testMessage));
  return service;
}

MockAuthServiceClient getMockAuthServiceClient() {
  final service = MockAuthServiceClient();
  when(service.checkQrCodeIsVerifiedAndLogin(any)).thenAnswer(
    (realInvocation) => MockResponseFuture<AccessTokenRes>(AccessTokenRes()),
  );
  when(service.verifyAndGetToken(any)).thenAnswer(
    (realInvocation) => MockResponseFuture<AccessTokenRes>(AccessTokenRes()),
  );
  return service;
}

MockMetaRepo getAndRegisterMetaRepo() {
  _removeRegistrationIfExists<MetaRepo>();
  final service = MockMetaRepo();
  GetIt.I.registerSingleton<MetaRepo>(service);
  when(service.isMessageContainMeta(any)).thenAnswer(
    (realInvocation) => true,
  );
  return service;
}

MockServicesDiscoveryRepo getAndRegisterServicesDiscoveryRepo({
  List<meta_pb.Meta>? metaList,
  int? fetchMetaListTime,
  GetMetaCountsRes? GetMetaCountsRe,
  int? fetchMetaListLimit,
  MetaGroup? fetchMetaListGroup,
  QueryDirection? fetchingDirectionType,
}) {
  _removeRegistrationIfExists<ServicesDiscoveryRepo>();
  final mockServicesDiscoveryRepo = MockServicesDiscoveryRepo();
  GetIt.I.registerSingleton<ServicesDiscoveryRepo>(mockServicesDiscoveryRepo);
  when(
    mockServicesDiscoveryRepo.queryServiceClient.getMetaCounts(
      GetMetaCountsReq()..roomUid = testUid,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<GetMetaCountsRes>(
      GetMetaCountsRe ??
          GetMetaCountsRes(
            allMediaCount: Int64(1),
          ),
    ),
  );
  when(
    mockServicesDiscoveryRepo.queryServiceClient.fetchMetaList(
      any,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchMetaListRes>(
      FetchMetaListRes(
        metaList: [],
      ),
    ),
  );
  when(
    mockServicesDiscoveryRepo.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(fetchMetaListTime ?? testMessage.time)
        ..group = fetchMetaListGroup ?? MetaGroup.MEDIA
        ..limit = fetchMetaListLimit ?? 20
        ..direction =
            fetchingDirectionType ?? QueryDirection.BACKWARD_INCLUSIVE,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchMetaListRes>(
      FetchMetaListRes(
        metaList: metaList ?? [],
      ),
    ),
  );
  return mockServicesDiscoveryRepo;
}

MockAnalyticsRepo getAndRegisterAnalyserRepo() {
  _removeRegistrationIfExists<AnalyticsRepo>();
  final service = MockAnalyticsRepo();
  GetIt.I.registerSingleton<AnalyticsRepo>(service);
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
  when(service.isRtl).thenAnswer((realInvocation) => true);
  when(service.locale).thenReturn(const Locale("en"));
  when(service.get(any)).thenReturn("d");
  when(service.get("you")).thenReturn("you");
  when(service.get("saved_message")).thenReturn("Saved Message");
  when(service.defaultTextDirection).thenReturn(TextDirection.ltr);
  return service;
}

MockMuteDao getAndRegisterMuteDao() {
  _removeRegistrationIfExists<MuteDao>();
  final service = MockMuteDao();
  GetIt.I.registerSingleton<MuteDao>(service);
  return service;
}

MockUidIdNameDao getAndRegisterUidIdNameDao({
  bool getByUidHasData = false,
  bool getUidByIdHasData = false,
}) {
  _removeRegistrationIfExists<UidIdNameDao>();
  final service = MockUidIdNameDao();
  GetIt.I.registerSingleton<UidIdNameDao>(service);
  when(service.getByUid(any)).thenAnswer(
    (realInvocation) => Future.value(
      getByUidHasData
          ? UidIdName(uid: testUid.asString(), name: "test", id: "test")
          : null,
    ),
  );
  when(service.search("test")).thenAnswer(
    (realInvocation) =>
        Future.value([UidIdName(uid: testUid.asString(), name: "test")]),
  );
  when(service.getUidById("test")).thenAnswer(
    (realInvocation) =>
        Future.value(getUidByIdHasData ? testUid.asString() : null),
  );
  when(service.watchIdByUid(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value("test"));

  return service;
}

MockContactRepo getAndRegisterContactRepo({
  bool getContactHasData = false,
  bool ignoreInsertingOrUpdatingContactDao = false,
  String? getContactFromServerData,
}) {
  _removeRegistrationIfExists<ContactRepo>();
  final service = MockContactRepo();
  GetIt.I.registerSingleton<ContactRepo>(service);
  when(service.getContact(testUid)).thenAnswer(
    (realInvocation) => Future.value(
      getContactHasData
          ? contact_pb.Contact(
              uid: testUid.asString(),
              firstName: "test",
              lastName: "test",
              countryCode: 98,
              nationalNumber: 9123456789,
            )
          : null,
    ),
  );
  when(
    service.getContactFromServer(
      testUid,
      ignoreInsertingOrUpdatingContactDao: ignoreInsertingOrUpdatingContactDao,
    ),
  ).thenAnswer((realInvocation) => Future.value(getContactFromServerData));
  return service;
}

MockAccountRepo getAndRegisterAccountRepo({bool hasProfile = false}) {
  _removeRegistrationIfExists<AccountRepo>();
  final service = MockAccountRepo();
  GetIt.I.registerSingleton<AccountRepo>(service);
  when(service.getName()).thenAnswer((realInvocation) => Future.value("test"));
  when(service.getAccount()).thenAnswer(
    (realInvocation) => Future.value(
      Account(
        username: "test",
      ),
    ),
  );
  when(
    service.hasProfile(
      retry: true,
    ),
  ).thenAnswer((realInvocation) => Future.value(hasProfile));

  when(service.fetchCurrentUserId(retry: true))
      .thenAnswer((realInvocation) => Future.value());

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

void getAndRegisterMessageExtractorServices() {
  _removeRegistrationIfExists<MessageExtractorServices>();
  GetIt.I
      .registerSingleton<MessageExtractorServices>(MessageExtractorServices());
}

MockCustomNotificationDao getAndRegisterCustomNotificationDao() {
  _removeRegistrationIfExists<CustomNotificationDao>();
  final service = MockCustomNotificationDao();
  GetIt.I.registerSingleton<CustomNotificationDao>(service);
  when(service.HaveCustomNotificationSound(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value(false));
  when(service.getCustomNotificationSound(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value("/test"));
  when(service.watchCustomNotificationSound(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.fromFuture(Future.value("/test")));
  return service;
}

MockMessageDao getAndRegisterMessageDao({
  Message? message,
  bool getError = false,
  PendingMessage? allPendingMessage,
  PendingMessage? pendingMessage,
  int getMessageId = 0,
}) {
  _removeRegistrationIfExists<MessageDao>();
  final service = MockMessageDao();
  GetIt.I.registerSingleton<MessageDao>(service);
  message == null
      ? getError
          ? when(service.getMessage(testUid.asString(), getMessageId))
              .thenThrow((realInvocation) => "error")
          : when(service.getMessage(testUid.asString(), getMessageId))
              .thenAnswer((realInvocation) => Future.value())
      : when(service.getMessage(testUid.asString(), getMessageId))
          .thenAnswer((realInvocation) => Future.value(message));
  when(service.getMessagePage(testUid.asString(), 0)).thenAnswer(
    (realInvocation) => Future.value([testMessage.copyWith(id: 0)]),
  );
  when(service.getAllPendingMessages()).thenAnswer(
    (realInvocation) => allPendingMessage != null
        ? Future.value([allPendingMessage])
        : Future.value([]),
  );
  when(service.getPendingMessage(any)).thenAnswer(
    (realInvocation) =>
        pendingMessage != null ? Future.value(pendingMessage) : Future.value(),
  );
  when(service.watchPendingMessage(""))
      .thenAnswer((realInvocation) => Stream.value(testPendingMessage));
  when(service.watchPendingMessages(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value([testPendingMessage]));
  when(service.getPendingMessages(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value([testPendingMessage]));
  when(
    service.getPendingMessage("94667220000013418"),
  ).thenAnswer((realInvocation) => Future.value(filePendingMessage));

  return service;
}

MockRoomDao getAndRegisterRoomDao({List<Room>? rooms}) {
  _removeRegistrationIfExists<RoomDao>();
  final service = MockRoomDao();
  GetIt.I.registerSingleton<RoomDao>(service);
  when(service.getRoom(testUid.asString())).thenAnswer(
    (realInvocation) =>
        Future.value(rooms?.first ?? Room(uid: testUid.asString())),
  );

  rooms ??= [
    Room(
      uid: testUid.asString(),
    )
  ];
  when(service.getAllRooms())
      .thenAnswer((realInvocation) => Future.value(rooms));
  when(service.getRoom(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value(rooms?.first));
  when(service.getRoom(testGroupUid.asString())).thenAnswer(
    (realInvocation) => Future.value(Room(uid: testGroupUid.asString())),
  );
  when(service.watchAllRooms())
      .thenAnswer((realInvocation) => Stream.value([testRoom]));
  when(service.watchRoom(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value(testRoom));
  when(service.getAllGroups())
      .thenAnswer((realInvocation) => Future.value([testRoom]));

  return service;
}

MockRoomRepo getAndRegisterRoomRepo({
  Room? room,
  bool getRoomGetError = false,
  bool isRoomBlocked = false,
  bool isRoomMuted = false,
}) {
  _removeRegistrationIfExists<RoomRepo>();
  final service = MockRoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  getRoomGetError
      ? when(service.getRoom(testUid.asString()))
          .thenThrow((realInvocation) => Future.value())
      : when(service.getRoom(testUid.asString())).thenAnswer(
          (realInvocation) =>
              Future.value(room ?? Room(uid: testUid.asString())),
        );
  when(service.isRoomBlocked(any)).thenAnswer(
    (realInvocation) => Future.value(isRoomBlocked),
  );

  when(service.processMentionIds(testGroupUid.asString(), [9]))
      .thenAnswer((realInvocation) => Future.value());
  when(service.isRoomMuted(any)).thenAnswer(
    (realInvocation) => Future.value(isRoomMuted),
  );

  when(service.getMySeen(any)).thenAnswer(
    (realInvocation) => Future.value(
      seen_box.Seen(
        uid: testUid.asString(),
        messageId: 0,
        hiddenMessageCount: 0,
      ),
    ),
  );

  when(service.getRoomLastMessageId(any)).thenAnswer(
    (realInvocation) => Future.value(0),
  );

  return service;
}

MockCallRepo getAndRegisterCallRepo() {
  _removeRegistrationIfExists<CallRepo>();
  final service = MockCallRepo();
  GetIt.I.registerSingleton<CallRepo>(service);
  return service;
}

RoomRepo getAndRegisterRealRoomRepo() {
  _removeRegistrationIfExists<RoomRepo>();
  final service = RoomRepo();
  GetIt.I.registerSingleton<RoomRepo>(service);
  return service;
}

MockAuthRepo getAndRegisterAuthRepo({
  bool isCurrentUser = false,
  bool isLoggedIn = true,
}) {
  _removeRegistrationIfExists<AuthRepo>();
  final service = MockAuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(service);
  when(service.isCurrentUser(any)).thenReturn(isCurrentUser);
  when(service.isCurrentUserUid(any)).thenReturn(isCurrentUser);
  when(service.currentUserUid).thenReturn(testUid);
  when(service.sendVerificationCode("12345"))
      .thenAnswer((d) => Future.value(AccessTokenRes()));
  when(service.checkQrCodeToken(any))
      .thenAnswer((f) => Future.value(AccessTokenRes()));
  service.newVersionInformation =
      BehaviorSubject.seeded(NewerVersionInformation());
  when(service.isLoggedIn()).thenReturn(isLoggedIn);
  return service;
}

MockFileRepo getAndRegisterFileRepo({file_pb.File? fileInfo}) {
  _removeRegistrationIfExists<FileRepo>();
  final service = MockFileRepo();
  GetIt.I.registerSingleton<FileRepo>(service);
  when(
    service.uploadClonedFile(
      "946672200000-0-13418",
      "test",
      sendActivity: anyNamed("sendActivity"),
      packetIds: ["946672200000-0-13418"],
    ),
  ).thenAnswer((realInvocation) => Future.value(fileInfo));
  when(
    service.uploadClonedFile(
      "94667220000013418",
      "test",
      sendActivity: anyNamed("sendActivity"),
      packetIds: ["94667220000013418"],
    ),
  ).thenAnswer((realInvocation) => Future.value(fileInfo));
  when(
    service.uploadClonedFile(
      "94667220000013418",
      "test",
      sendActivity: anyNamed("sendActivity"),
      packetIds: ["946672200000-0-13418"],
    ),
  ).thenAnswer((realInvocation) => Future.value(fileInfo));
  when(
    service.uploadClonedFile(
      "946672200000",
      "test",
      packetIds: [],
    ),
  ).thenAnswer((realInvocation) => Future.value(fileInfo));

  return service;
}

MockLiveLocationRepo getAndRegisterLiveLocationRepo() {
  _removeRegistrationIfExists<LiveLocationRepo>();
  final service = MockLiveLocationRepo();
  GetIt.I.registerSingleton<LiveLocationRepo>(service);
  when(service.createLiveLocation(testUid, 0)).thenAnswer(
    (realInvocation) => MockResponseFuture<CreateLiveLocationRes>(
      CreateLiveLocationRes(uuid: testUid.asString()),
    ),
  );
  return service;
}

MockMetaDao getAndRegisterMetaDao({
  int? IndexOfMedia = 0,
  MetaType? getMediaType = MetaType.MEDIA,
  List<Meta>? getMetaPage,
}) {
  _removeRegistrationIfExists<MetaDao>();
  final service = MockMetaDao();
  GetIt.I.registerSingleton<MetaDao>(service);
  when(service.clearAllMetas(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value());
  when(service.getIndexOfMetaFromMessageId(testUid.asString(), 0))
      .thenAnswer((realInvocation) => Future.value(IndexOfMedia));
  when(service.getMetaPage(testUid.asString(), getMediaType, 0)).thenAnswer(
    (realInvocation) => Future.value(getMetaPage ?? []),
  );
  return service;
}

MockMetaCountDao getAndRegisterMetaCountDataDao({
  MetaCount? metaCount,
}) {
  _removeRegistrationIfExists<MetaCountDao>();
  final service = MockMetaCountDao();
  GetIt.I.registerSingleton<MetaCountDao>(service);
  when(service.clear(testUid.asString()))
      .thenAnswer((realInvocation) => Future.value());
  when(
    service.getAsFuture(testUid.asString()),
  ).thenAnswer(
    (realInvocation) => Future.value(metaCount),
  );
  when(
    service.get(testUid.asString()),
  ).thenAnswer(
    (realInvocation) => Stream.value(metaCount),
  );
  return service;
}

MockMucDao getAndRegisterMucDao() {
  _removeRegistrationIfExists<MucDao>();
  final service = MockMucDao();
  GetIt.I.registerSingleton<MucDao>(service);
  when(service.get(testUid.asString())).thenAnswer(
    (realInvocation) =>
        Future.value(Muc(uid: testUid.asString(), pinMessagesIdList: [])),
  );
  return service;
}

MockCallService getAndRegisterCallService() {
  _removeRegistrationIfExists<CallService>();
  final service = MockCallService();
  GetIt.I.registerSingleton<CallService>(service);
  return service;
}

MockLastActivityDao getAndRegisterLastActivityDao() {
  _removeRegistrationIfExists<LastActivityDao>();
  final service = MockLastActivityDao();
  GetIt.I.registerSingleton<LastActivityDao>(service);
  return service;
}

MockNotificationServices getAndRegisterNotificationServices() {
  _removeRegistrationIfExists<NotificationServices>();
  final service = MockNotificationServices();
  GetIt.I.registerSingleton<NotificationServices>(service);
  return service;
}

MockAppLifecycleService getAndRegisterAppLifecycleService({
  bool appIsActive = true,
}) {
  _removeRegistrationIfExists<AppLifecycleService>();
  final service = MockAppLifecycleService();
  GetIt.I.registerSingleton<AppLifecycleService>(service);
  when(service.isActive).thenAnswer((realInvocation) => appIsActive);
  return service;
}

MockSeenDao getAndRegisterSeenDao({int messageId = 0}) {
  _removeRegistrationIfExists<SeenDao>();
  final service = MockSeenDao();
  GetIt.I.registerSingleton<SeenDao>(service);
  when(service.getOthersSeen(testUid.asString())).thenAnswer(
    (realInvocation) => Future.value(
      seen_box.Seen(
        uid: testUid.asString(),
        messageId: messageId,
        hiddenMessageCount: 0,
      ),
    ),
  );
  when(service.getMySeen(any)).thenAnswer(
    (realInvocation) => Future.value(
      seen_box.Seen(
        uid: testUid.asString(),
        messageId: messageId,
        hiddenMessageCount: 0,
      ),
    ),
  );
  when(service.getMySeen(testUid.asString())).thenAnswer(
    (realInvocation) => Future.value(
      seen_box.Seen(
        uid: testUid.asString(),
        messageId: messageId,
        hiddenMessageCount: 0,
      ),
    ),
  );
  when(service.getRoomSeen(testUid.asString())).thenAnswer(
    (realInvocation) => Future.value(testRoom.uid),
  );
  when(service.getRoomSeen(testGroupUid.asString())).thenAnswer(
    (realInvocation) => Future.value(testGroupUid.asString()),
  );
  when(service.watchMySeen(testUid.asString()))
      .thenAnswer((realInvocation) => Stream.value(testSeen));
  return service;
}

MockMucServices getAndRegisterMucServices() {
  _removeRegistrationIfExists<MucServices>();
  final service = MockMucServices();
  GetIt.I.registerSingleton<MucServices>(service);

  when(service.pinMessage(testMessage))
      .thenAnswer((realInvocation) => Future.value());
  when(service.unpinMessage(testMessage))
      .thenAnswer((realInvocation) => Future.value());
  return service;
}

MockQueryServiceClient getMockQueryServicesClient({
  bool finished = true,
  PresenceType presenceType = PresenceType.ACTIVE,
  int lastMessageId = 10,
  Uid? roomUid,
  int lastUpdate = roomMetaDataLastUpdateTime,
  int fetchMessagesId = 0,
  int lastCurrentUserSentMessageId = 8,
  int lastSeenId = 9,
  int hiddenMessageCount = 1,
  int fetchHiddenMessageCountMessageId = 10,
  String? fetchMessagesText,
  int fetchMessagesLimit = 0,
  bool fetchMessagesHasOptions = true,
  FetchMessagesReq_Type fetchMessagesType =
      FetchMessagesReq_Type.BACKWARD_FETCH,
  int fetchMessagesPointer = 0,
  bool justNotHiddenMessages = false,
  PersistentEvent? fetchMessagesPersistEvent,
  int? mentionIdList,
  int updateMessageId = 0,
  bool updateMessageGetError = false,
  bool removePrivateRoomGetError = false,
  bool getIdByUidGetError = false,
  String? getIdByUidData,
  message_pb.MessageByClient? updatedMessageFile,
}) {
  final queryServiceClient = MockQueryServiceClient();

  final roomMetadata = RoomMetadata(
    roomUid: roomUid ?? testUid,
    lastMessageId: Int64(lastMessageId),
    lastCurrentUserSentMessageId: Int64(lastCurrentUserSentMessageId),
    lastUpdate: Int64(lastUpdate),
    lastSeenId: Int64(lastSeenId),
    presenceType: presenceType,
  );
  final Iterable<RoomMetadata> roomsMeta = {roomMetadata};
  when(
    queryServiceClient.getAllUserRoomMeta(
      GetAllUserRoomMetaReq()
        ..pointer = 0
        ..limit = FETCH_ROOM_METADATA_LIMIT,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<GetAllUserRoomMetaRes>(
      GetAllUserRoomMetaRes(roomsMeta: roomsMeta, finished: finished),
    ),
  );
  when(
    queryServiceClient.getUserRoomMeta(GetUserRoomMetaReq()..roomUid = testUid),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<GetUserRoomMetaRes>(
      GetUserRoomMetaRes(roomMeta: roomMetadata),
    ),
  );

  when(
    queryServiceClient.countIsHiddenMessages(
      CountIsHiddenMessagesReq()
        ..roomUid = testUid
        ..messageId = Int64(fetchHiddenMessageCountMessageId),
    ),
  ).thenAnswer(
    (realInvocation) =>
        MockResponseFuture(CountIsHiddenMessagesRes(count: hiddenMessageCount)),
  );
  when(
    queryServiceClient.fetchCurrentUserSeenData(
      FetchCurrentUserSeenDataReq()..roomUid = testUid,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchCurrentUserSeenDataRes>(
      FetchCurrentUserSeenDataRes(
        seen: seen_pb.Seen(from: testUid, to: testUid, id: Int64()),
      ),
    ),
  );
  when(
    queryServiceClient.fetchLastOtherUserSeenData(
      FetchLastOtherUserSeenDataReq()..roomUid = testUid,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchLastOtherUserSeenDataRes>(
      FetchLastOtherUserSeenDataRes(
        seen: seen_pb.Seen(from: testUid, to: testUid),
      ),
    ),
  );
  when(
    queryServiceClient.countIsHiddenMessages(any),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<CountIsHiddenMessagesRes>(
      CountIsHiddenMessagesRes(count: 0),
    ),
  );

  when(
    queryServiceClient.fetchMessages(
      FetchMessagesReq(
        justNotHiddenMessages: justNotHiddenMessages ? true : null,
      )
        ..roomUid = testUid
        ..pointer = Int64(fetchMessagesPointer)
        ..type = fetchMessagesType
        ..limit = fetchMessagesLimit,
      options: fetchMessagesHasOptions
          ? CallOptions(timeout: const Duration(seconds: 3))
          : null,
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchMessagesRes>(
      FetchMessagesRes(
        messages: {
          message_pb.Message(
            packetId: "",
            time: Int64(),
            id: Int64(fetchMessagesId),
            to: testUid,
            from: testUid,
            text: fetchMessagesText != null
                ? message_pb.Text(text: fetchMessagesText)
                : null,
            persistEvent: fetchMessagesPersistEvent,
            edited: false,
            replyToId: Int64(),
            forwardFrom: testUid,
            encrypted: false,
          )
        },
      ),
    ),
  );
  when(
    queryServiceClient.fetchMentionList(
      FetchMentionListReq()
        ..group = testGroupUid
        ..afterId = Int64(10),
    ),
  ).thenAnswer(
    (realInvocation) => MockResponseFuture<FetchMentionListRes>(
      FetchMentionListRes(
        idList: mentionIdList != null ? [Int64(mentionIdList)] : [],
      ),
    ),
  );
  when(
    queryServiceClient.deleteMessage(
      DeleteMessageReq()
        ..messageId = Int64()
        ..roomUid = testUid,
    ),
  ).thenAnswer(
    (realInvocation) =>
        MockResponseFuture<DeleteMessageRes>(DeleteMessageRes()),
  );
  final updatedMessage = message_pb.MessageByClient()
    ..to = testMessage.to.asUid()
    ..replyToId = Int64(testMessage.replyToId)
    ..text = message_pb.Text(text: "editText");
  updateMessageGetError
      ? when(
          queryServiceClient.updateMessage(
            UpdateMessageReq()
              ..message = updatedMessageFile ?? updatedMessage
              ..messageId = Int64(updateMessageId),
          ),
        ).thenThrow(
          (realInvocation) =>
              MockResponseFuture<UpdateMessageRes>(UpdateMessageRes()),
        )
      : when(
          queryServiceClient.updateMessage(
            UpdateMessageReq()
              ..message = updatedMessageFile ?? updatedMessage
              ..messageId = Int64(updateMessageId),
          ),
        ).thenAnswer(
          (realInvocation) =>
              MockResponseFuture<UpdateMessageRes>(UpdateMessageRes()),
        );
  when(queryServiceClient.getBlockedList(GetBlockedListReq())).thenAnswer(
    (realInvocation) => MockResponseFuture<GetBlockedListRes>(
      GetBlockedListRes(uidList: [testUid]),
    ),
  );
  removePrivateRoomGetError
      ? when(
          queryServiceClient
              .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid),
        ).thenThrow(
          (realInvocation) =>
              MockResponseFuture<RemovePrivateRoomRes>(RemovePrivateRoomRes()),
        )
      : when(
          queryServiceClient
              .removePrivateRoom(RemovePrivateRoomReq()..roomUid = testUid),
        ).thenAnswer(
          (realInvocation) =>
              MockResponseFuture<RemovePrivateRoomRes>(RemovePrivateRoomRes()),
        );
  getIdByUidGetError
      ? when(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = testUid))
          .thenThrow(
          (realInvocation) =>
              MockResponseFuture<GetIdByUidRes>(GetIdByUidRes()),
        )
      : when(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = testUid))
          .thenAnswer(
          (realInvocation) => MockResponseFuture<GetIdByUidRes>(
            GetIdByUidRes(id: getIdByUidData),
          ),
        );
  getIdByUidGetError
      ? when(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = groupUid))
          .thenThrow(
          (realInvocation) =>
              MockResponseFuture<GetIdByUidRes>(GetIdByUidRes()),
        )
      : when(queryServiceClient.getIdByUid(GetIdByUidReq()..uid = groupUid))
          .thenAnswer(
          (realInvocation) => MockResponseFuture<GetIdByUidRes>(
            GetIdByUidRes(id: getIdByUidData),
          ),
        );
  when(queryServiceClient.blockUid(BlockUidReq()..uid = testUid)).thenAnswer(
    (realInvocation) => MockResponseFuture<BlockUidRes>(BlockUidRes()),
  );
  when(queryServiceClient.unblockUid(UnblockUidReq()..uid = testUid))
      .thenAnswer(
    (realInvocation) => MockResponseFuture<UnblockUidRes>(UnblockUidRes()),
  );
  when(queryServiceClient.getUidById(GetUidByIdReq()..id = "test")).thenAnswer(
    (realInvocation) =>
        MockResponseFuture<GetUidByIdRes>(GetUidByIdRes(uid: testUid)),
  );
  when(queryServiceClient.report(ReportReq()..uid = testUid)).thenAnswer(
    (realInvocation) => MockResponseFuture<ReportRes>(ReportRes()),
  );
  return queryServiceClient;
}

MockSharedDao getAndRegisterSharedDao({
  bool allRoomFetched = false,
  bool showCaseEnable = false,
}) {
  _removeRegistrationIfExists<SharedDao>();
  final service = MockSharedDao();
  GetIt.I.registerSingleton<SharedDao>(service);
  // when(service.getBoolean(SharedKeys.SHARED_DAO_ALL_ROOMS_FETCHED))
  //     .thenAnswer((realInvocation) => Future.value(allRoomFetched));
  // when(service.getBooleanStream(SharedKeys.SHARED_DAO_IS_SHOWCASE_ENABLE))
  //     .thenAnswer((realInvocation) => Stream.value(showCaseEnable));
  return service;
}

MessageRepo getAndRegisterMessageRepo() {
  _removeRegistrationIfExists<MessageRepo>();
  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
  final service = GetIt.I.get<MessageRepo>();
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

MockUrlHandlerService getAndRegisterUrlHandlerService() {
  _removeRegistrationIfExists<MockUrlHandlerService>();
  final service = MockUrlHandlerService();
  GetIt.I.registerSingleton<UrlHandlerService>(service);
  return service;
}

void registerServices() {
  getAndRegisterAnalyserRepo();
  getAndRegisterServicesDiscoveryRepo();
  getAndRegisterMetaRepo();
  getAndRegisterLogger();
  getAndRegisterDataStreamServices();
  getAndRegisterCoreServices();
  getAndRegisterMessageDao();
  getAndRegisterRoomDao();
  getAndRegisterRoomRepo();
  getAndRegisterRoutingServices();
  getAndRegisterAudioServices();
  getAndRegisterAnalyticsService();
  getAndRegisterFileService();
  setInitializeValueForSharedPreferences();
  getAndRegisterAuthRepo();
  getAndRegisterFileRepo();
  getAndRegisterLiveLocationRepo();
  getAndRegisterSeenDao();
  getAndRegisterMucServices();
  getAndRegisterSharedDao();
  getAndRegisterAvatarRepo();
  getAndRegisterBlockDao();
  getAndRegisterFireBaseServices();
  getAndRegisterI18N();
  getAndRegisterCallRepo();
  getAndRegisterMuteDao();
  getAndRegisterUidIdNameDao();
  getAndRegisterContactRepo();
  getAndRegisterAccountRepo();
  getAndRegisterMucRepo();
  getAndRegisterBotRepo();
  getAndRegisterMetaDao();
  getAndRegisterCustomNotificationDao();
  getAndRegisterMetaCountDataDao();
  getAndRegisterCallService();
  getAndRegisterMessageExtractorServices();
  getAndRegisterNotificationServices();
  getAndRegisterAppLifecycleService();
  getAndRegisterLastActivityDao();
  getAndRegisterMucDao();
  getAndRegisterUxService();
  getAndRegisterUrlHandlerService();
}

void unregisterServices() => GetIt.I.reset();

void _removeRegistrationIfExists<T extends Object>() {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }
}
