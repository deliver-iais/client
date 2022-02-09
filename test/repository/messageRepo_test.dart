import 'package:clock/clock.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import '../helper/test_helper.dart';

Uid testUid = "0:3049987b-e15d-4288-97cd-42dbc6d73abd".asUid();
Message testMessage = Message(
    to: testUid.asString(),
    from: testUid.asString(),
    packetId: testUid.asString(),
    roomUid: testUid.asString(),
    time: 0);

void main() {
  group('MessageRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('MessageRepo -', () {
      test('When called should check coreServices.connectionStatus', () async {
        final coreServices = getAndRegisterCoreServices();
        MessageRepo();
        verify(coreServices.connectionStatus);
      });
      test(
          'When called should check if coreServices.connectionStatus is connected we should see updating log',
          () async {
        final logger = getAndRegisterLogger();
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        // ignore: await_only_futures
        await MessageRepo();
        verify(logger.i('updating -----------------'));
      });
      test(
          'When called should check if coreServices.connectionStatus is connected  updatingStatus should be TitleStatusConditions.Updating',
          () async {
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        MessageRepo messageRepo = await getAndRegisterMessageRepo();
        expect(
            messageRepo.updatingStatus.value, TitleStatusConditions.Updating);
      });

      test(
          'When called should check if coreServices.connectionStatus is disconnected updatingStatus should be TitleStatusConditions.Disconnected',
          () async {
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Disconnected);
        MessageRepo messageRepo = await getAndRegisterMessageRepo();
        expect(messageRepo.updatingStatus.value,
            TitleStatusConditions.Disconnected);
      });

      test(
          'When called should check if coreServices.connectionStatus is Connecting updatingStatus should be TitleStatusConditions.Connecting',
          () async {
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connecting);
        MessageRepo messageRepo = await getAndRegisterMessageRepo();
        expect(
            messageRepo.updatingStatus.value, TitleStatusConditions.Connecting);
      });
    });

    group('updateNewMuc -', () {
      //todo need better test for time
      test('When called should update roomDao', () async {
        final roomDao = getAndRegisterRoomDao();
        MessageRepo().updateNewMuc(testUid, 0);
        verifyNever(roomDao.updateRoom(Room(
          uid: testUid.asString(),
          lastMessageId: 0,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
        )));
      });
    });

    group('updatingMessages -', () {
      test('When called should fetch all room from sharedDao', () async {
        final sharedDao = getAndRegisterSharedDao();
        MessageRepo().updatingMessages();
        verify(sharedDao.get(SHARED_DAO_FETCH_ALL_ROOM));
      });

      test('When called should get All UserRoomMeta', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await MessageRepo().updatingMessages();
        verify(queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
          ..pointer = 0
          ..limit = 10));
      });
      test(
          'When called should get All UserRoomMeta and if finished be true should put on sharedDao',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        final sharedDao = getAndRegisterSharedDao();
        await MessageRepo().updatingMessages();
        var getAllUserRoomMetaRes =
            await queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
              ..pointer = 0
              ..limit = 10);
        expect(getAllUserRoomMetaRes.finished, true);
        verify(sharedDao.put(SHARED_DAO_FETCH_ALL_ROOM, "true"));
      });
      test(
          'When called should get All UserRoomMeta and if finished be false should never put on sharedDao',
          () async {
        final queryServiceClient =
            getAndRegisterQueryServiceClient(finished: false);
        final sharedDao = getAndRegisterSharedDao();
        await MessageRepo().updatingMessages();
        var getAllUserRoomMetaRes =
            await queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
              ..pointer = 0
              ..limit = 10);
        expect(getAllUserRoomMetaRes.finished, false);
        verifyNever(sharedDao.put(SHARED_DAO_FETCH_ALL_ROOM, "true"));
      });

      test('When called should get room from roomDao', () async {
        final roomDao = getAndRegisterRoomDao();
        await MessageRepo().updatingMessages();
        verify(roomDao.getRoom(testUid.asString()));
      });

      test(
          'When called if roomMetadata.presenceType be Active and room last message id and last update be greater than roomMetadata should stop getting room',
          () async {
        getAndRegisterQueryServiceClient(
            presenceType: PresenceType.ACTIVE, lastMessageId: 0, lastUpdate: 0);
        final roomDao = getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(),
              lastMessageId: 0,
              lastUpdateTime: 0,
              lastMessage: testMessage.copyWith(id: 1))
        ]);
        await MessageRepo().updatingMessages();
        verify(roomDao.getRoom(testUid.asString())).called(1);
      });

      test(
          'When called if roomMetadata.presenceType be Active and rooms deleted being true should update the room',
          () async {
        getAndRegisterQueryServiceClient(presenceType: PresenceType.ACTIVE);
        final roomDao = getAndRegisterRoomDao(rooms: [
          Room(
            uid: testUid.asString(),
            deleted: true,
          )
        ]);
        await MessageRepo().updatingMessages();
        verify(roomDao.updateRoom(Room(
            uid: testUid.asString(),
            deleted: false,
            lastMessageId: 0,
            firstMessageId: 0,
            lastUpdateTime: 0)));
      });

      test(
          'When called if roomMetadata.presenceType not be Active should updateRoom',
          () async {
        getAndRegisterQueryServiceClient(presenceType: PresenceType.DELETED);
        final roomDao = getAndRegisterRoomDao();
        await MessageRepo().updatingMessages();
        verify(roomDao.updateRoom(Room(
            uid: testUid.asString(),
            deleted: true,
            lastMessageId: 0,
            firstMessageId: 0,
            lastUpdateTime: 0)));
      });
    });

    group('updatingLastSeen -', () {
      test('When called should fetch all room from roomDao', () async {
        final roomDao = getAndRegisterRoomDao();
        MessageRepo().updatingLastSeen();
        verify(roomDao.getAllRooms());
      });

      test(
          'When called should fetch all room from roomDao and if any room exist should get category',
          () async {
        final roomDao = getAndRegisterRoomDao(
            rooms: [Room(uid: testUid.asString(), lastMessage: testMessage)]);
        var rooms = await roomDao.getAllRooms();
        MessageRepo().updatingLastSeen();
        expect(rooms.first.lastMessage!.to.asUid().category, Categories.USER);
      });
      test(
          'When called should fetch all room from roomDao and if last message id be null should return',
          () async {
        final seenDo = getAndRegisterSeenDao();
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        getAndRegisterRoomDao(
            rooms: [Room(uid: testUid.asString(), lastMessage: testMessage)]);
        await MessageRepo().updatingLastSeen();
        verifyNever(authRepo.isCurrentUser(testUid.asString()));
        verifyNever(seenDo.getOthersSeen(testUid.asString()));
      });
      test(
          'When called should fetch all room from roomDao and if last message id not be null should check isCurrentUser',
          () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        final queryServiceClient = getAndRegisterQueryServiceClient();
        getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(), lastMessage: testMessage.copyWith(id: 0))
        ]);
        await MessageRepo().updatingLastSeen();
        verify(authRepo.isCurrentUser(testUid.asString()));
        verifyNever(queryServiceClient
            .getUserRoomMeta(GetUserRoomMetaReq()..roomUid = testUid));
      });
      test(
          'When called should fetch all room from roomDao and if last message id not be null and isCurrentUser be false should get user room meta',
          () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: false);
        final queryServiceClient = getAndRegisterQueryServiceClient();
        getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(), lastMessage: testMessage.copyWith(id: 0))
        ]);

        await MessageRepo().updatingLastSeen();
        verify(authRepo.isCurrentUser(testUid.asString()));
        verify(queryServiceClient
            .getUserRoomMeta(GetUserRoomMetaReq()..roomUid = testUid));
      });
      test('When called if lastMessage id not be null should getOthersSeen ',
          () async {
        final seenDo = getAndRegisterSeenDao();
        getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(), lastMessage: testMessage.copyWith(id: 0))
        ]);
        await MessageRepo().updatingLastSeen();
        verify(seenDo.getOthersSeen(testUid.asString()));
      });
    });

    group('fetchHiddenMessageCount -', () {
      test('When called should countIsHiddenMessages', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        verify(
            queryServiceClient.countIsHiddenMessages(CountIsHiddenMessagesReq()
              ..roomUid = testUid
              ..messageId = Int64(0 + 1)));
      });

      test('When called should getMySeen', () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        verify(seenDo.getMySeen(testUid.asString()));
      });
      test('When called should getMySeen anf if is not null should save it',
          () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        var s = await seenDo.getMySeen(testUid.asString());
        verify(seenDo.saveMySeen(
            s?.copy(Seen(uid: testUid.asString(), hiddenMessageCount: 0))));
      });
      test('When called should getMySeen and if is null should never save it',
          () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        var s = await seenDo.getMySeen(testUid.asString());
        verifyNever(seenDo.saveMySeen(
            s?.copy(Seen(uid: testUid.asString(), hiddenMessageCount: 0))));
      });
    });

    group('fetchLastMessages -', () {
      test('When called should getMessage from messageDao', () async {
        final messageDao = getAndRegisterMessageDao();
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(messageDao.getMessage(testUid.asString(), 0));
      });
      test(
          'When called should getMessage from messageDao if msg be null and get error should returned null',
          () async {
        getAndRegisterMessageDao(getError: true);
        expect(
            await MessageRepo().fetchLastMessages(
              testUid,
              0,
              0,
              Room(uid: testUid.asString()),
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 2,
            ),
            null);
      });
      test(
          'When called should getMessage from messageDao if msg be null  and get error should updateRoom',
          () async {
        getAndRegisterMessageDao(getError: true);
        final roomDao = getAndRegisterRoomDao();
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(roomDao.updateRoom(Room(
          uid: testUid.asString(),
          firstMessageId: 0,
          lastUpdateTime: 0,
          lastMessageId: 0,
        )));
      });
      test(
          'When called should getMessage from messageDao if msg be null and get error should see logger',
          () async {
        getAndRegisterMessageDao(getError: true);
        final logger = getAndRegisterLogger();
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(logger.wtf(testUid));
        verify(logger.wtf(Room(uid: testUid.asString())));
      });

      test('When called should getMessage from messageDao if msg be null ',
          () async {
        getAndRegisterMessageDao(getError: false);
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 0,
        );
        expect(
            await MessageRepo().fetchLastMessages(
              testUid,
              0,
              0,
              Room(uid: testUid.asString()),
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 0,
            ),
            Message(
                roomUid: testUid.asString(),
                packetId: "",
                time: 0,
                id: 0,
                json: "{DELETED}",
                forwardedFrom: testUid.asString(),
                type: MessageType.NOT_SET,
                to: testUid.asString(),
                from: testUid.asString(),
                edited: false,
                replyToId: 0,
                encrypted: false));
      });

      test(
          'When called should getMessage from messageDao if msg not be null and firstMessageId be greater then  message id  should updateRoom with json "{DELETED}" and return it',
          () async {
        Message message = Message(
            id: 0,
            from: testUid.asString(),
            to: testUid.asString(),
            packetId: testUid.asString(),
            time: 0,
            json: "{DELETED}",
            roomUid: testUid.asString());
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(message: message);
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(roomDao.updateRoom(
          Room(
              uid: testUid.asString(),
              firstMessageId: 0,
              lastUpdateTime: 0,
              lastMessageId: 0,
              lastMessage: message),
        ));
        expect(
            await MessageRepo().fetchLastMessages(
              testUid,
              0,
              0,
              Room(uid: testUid.asString()),
              lastUpdateTime: 0,
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 2,
            ),
            message);
      });
      test(
          'When called should getMessage from messageDao if msg not be null and message json not be {}  should updateRoom without no chang in lastMessage and return it',
          () async {
        Message message = Message(
            id: 3,
            from: testUid.asString(),
            to: testUid.asString(),
            packetId: testUid.asString(),
            time: 0,
            json: "{test}",
            roomUid: testUid.asString());
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(message: message);
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(roomDao.updateRoom(
          Room(
              uid: testUid.asString(),
              firstMessageId: 0,
              lastUpdateTime: 0,
              lastMessageId: 0,
              lastMessage: message),
        ));
        expect(
            await MessageRepo().fetchLastMessages(
              testUid,
              0,
              0,
              Room(uid: testUid.asString()),
              lastUpdateTime: 0,
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 2,
            ),
            message);
      });
      test(
          'When called should getMessage from messageDao if msg not be null and  message id be 1 should updateRoom with json "{DELETED}" and return it',
          () async {
        Message message = Message(
            id: 1,
            from: testUid.asString(),
            to: testUid.asString(),
            packetId: testUid.asString(),
            time: 0,
            json: "{DELETED}",
            roomUid: testUid.asString());
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(message: testMessage.copyWith(id: 1));
        await MessageRepo().fetchLastMessages(
          testUid,
          0,
          0,
          Room(uid: testUid.asString()),
          lastUpdateTime: 0,
          type: FetchMessagesReq_Type.BACKWARD_FETCH,
          limit: 2,
        );
        verify(roomDao.updateRoom(
          Room(
              uid: testUid.asString(),
              firstMessageId: 0,
              lastUpdateTime: 0,
              lastMessageId: 0,
              lastMessage: message),
        ));
        expect(
            await MessageRepo().fetchLastMessages(
              testUid,
              0,
              0,
              Room(uid: testUid.asString()),
              lastUpdateTime: 0,
              type: FetchMessagesReq_Type.BACKWARD_FETCH,
              limit: 2,
            ),
            message);
      });
    });

    group('getLastMessageFromServer -', () {
      Message message = Message(
          roomUid: testUid.asString(),
          packetId: "",
          time: 0,
          id: 0,
          json: "{DELETED}",
          forwardedFrom: testUid.asString(),
          type: MessageType.NOT_SET,
          to: testUid.asString(),
          from: testUid.asString(),
          edited: false,
          replyToId: 0,
          encrypted: false);
      test('When called should fetchMessages from queryServiceClient',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await MessageRepo().getLastMessageFromServer(
            testUid, 0, 0, FetchMessagesReq_Type.BACKWARD_FETCH, 0, 0, 0);
        verify(queryServiceClient.fetchMessages(
            FetchMessagesReq()
              ..roomUid = testUid
              ..pointer = Int64(0)
              ..type = FetchMessagesReq_Type.BACKWARD_FETCH
              ..limit = 0,
            options: CallOptions(timeout: const Duration(seconds: 3))));
      });
      test(
          'When called should fetchMessages from queryServiceClient and if element.id! <= firstMessageId be false and json not be {} should return lastMessage without any copy',
          () async {
        getAndRegisterQueryServiceClient(
            fetchMessagesId: 2, fetchMessagesText: "test");
        expect(
            await MessageRepo().getLastMessageFromServer(
                testUid, 0, 0, FetchMessagesReq_Type.BACKWARD_FETCH, 0, 0, 0),
            message.copyWith(
                id: 2, json: "{\"1\":\"test\"}", type: MessageType.TEXT));
      });
      test(
          'When called should fetchMessages from queryServiceClient and if element.id! <= firstMessageId be false and id==1 should copy "{DELETED}" to lastMessage',
          () async {
        getAndRegisterQueryServiceClient(fetchMessagesId: 1);
        expect(
            await MessageRepo().getLastMessageFromServer(
                testUid, 0, 0, FetchMessagesReq_Type.BACKWARD_FETCH, 0, 0, 0),
            message.copyWith(id: 1));
      });
      test(
          'When called should fetchMessages from queryServiceClient and if element.id! <= firstMessageId should copy "{DELETED}" to lastMessage',
          () async {
        expect(
            await MessageRepo().getLastMessageFromServer(
                testUid, 0, 0, FetchMessagesReq_Type.BACKWARD_FETCH, 0, 0, 0),
            message);
      });
    });
    group('fetchOtherSeen -', () {
      test(
          'When called if user category being USER or GROUP should fetchLastOtherUserSeenData and save MySeen',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchOtherSeen(testUid);
        verify(queryServiceClient.fetchLastOtherUserSeenData(
            FetchLastOtherUserSeenDataReq()..roomUid = testUid));
        verify(
            seenDo.saveOthersSeen(Seen(uid: testUid.asString(), messageId: 0)));
      });
    });
    group('fetchCurrentUserLastSeen -', () {
      RoomMetadata roomMetadata = RoomMetadata(
          roomUid: testUid,
          lastMessageId: null,
          firstMessageId: null,
          lastCurrentUserSentMessageId: null,
          lastUpdate: null,
          presenceType: PresenceType.ACTIVE);

      test('When called should fetch CurrentUser SeenData', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verify(queryServiceClient.fetchCurrentUserSeenData(
            FetchCurrentUserSeenDataReq()..roomUid = testUid));
      });
      test('When called should get My Seen', () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verify(seenDo.getMySeen(testUid.asString()));
      });
      test(
          'When called should get My Seen if lastSeen messageId be null should save it',
          () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verify(await seenDo.saveMySeen(Seen(
            uid: testUid.asString(), hiddenMessageCount: 0, messageId: 0)));
      });
      test(
          'When called should get My Seen if lastSeen messageId not be null and last seen messageId be greater than lastCurrentUserSentMessageId should return',
          () async {
        final seenDo = getAndRegisterSeenDao(messageId: 1);
        await MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verifyNever(await seenDo.saveMySeen(Seen(
            uid: testUid.asString(), hiddenMessageCount: 0, messageId: 0)));
      });
    });
    group('getMentions -', () {
      test('When called should fetchMentionList from  queryServiceClient',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await MessageRepo().getMentions(Room(
            uid: testUid.asString(), lastMessage: testMessage.copyWith(id: 0)));
        verify(queryServiceClient.fetchMentionList(FetchMentionListReq()
          ..group = testUid
          ..afterId = Int64.parseInt("0")));
      });
      test(
          'When called should fetchMentionList from  queryServiceClient and  if idList not be empty should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterQueryServiceClient(mentionIdList: 0);
        await MessageRepo().getMentions(Room(
            uid: testUid.asString(), lastMessage: testMessage.copyWith(id: 0)));
        verify(
            roomDao.updateRoom(Room(uid: testUid.asString(), mentioned: true)));
      });
    });
    group('sendTextMessage -', () {
      PendingMessage pm = PendingMessage(
          roomUid: testUid.asString(),
          packetId: "946672200000000",
          msg: testMessage.copyWith(
              type: MessageType.TEXT,
              time: 946672200000,
              packetId: "946672200000000",
              json: "{\"1\":\"test\"}"),
          status: SendingStatus.PENDING,
          failed: false);

      test('When called should savePendingMessage', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final messageDao = getAndRegisterMessageDao();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendTextMessage(testUid, "test");
            verify(messageDao.savePendingMessage(pm));
          },
        );
      });
    });
  });
}
