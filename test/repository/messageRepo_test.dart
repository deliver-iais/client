import 'dart:async';

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
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import '../helper/test_helper.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart'
    as location_pb;
import 'package:deliver/models/file.dart' as model;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/seen.pb.dart' as seen_pb;
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';

Uid testUid = "0:3049987b-e15d-4288-97cd-42dbc6d73abd".asUid();
Message testMessage = Message(
    to: testUid.asString(),
    from: testUid.asString(),
    packetId: testUid.asString(),
    roomUid: testUid.asString(),
    time: 0,
    json: '');
PendingMessage testPendingMessage = PendingMessage(
    roomUid: testUid.asString(),
    packetId: "946672200000000",
    msg: testMessage.copyWith(
      time: 946672200000,
      packetId: "946672200000000",
    ),
    failed: false,
    status: SendingStatus.PENDING);

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
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            MessageRepo().updateNewMuc(testUid, 0);
            verify(roomDao.updateRoom(Room(
              uid: testUid.asString(),
              lastMessageId: 0,
              lastUpdateTime: clock.now().millisecondsSinceEpoch,
            )));
          },
        );
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
      test('When called should getMySeen and should save it', () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        var s = await seenDo.getMySeen(testUid.asString());
        verify(seenDo.saveMySeen(s.copy(
            newUid: testUid.asString(),
            newMessageId: 0,
            newHiddenMessageCount: 0)));
      });
      test('When called should countIsHiddenMessages', () async {
        final seenDo = getAndRegisterSeenDao();
        getAndRegisterQueryServiceClient(countIsHiddenMessagesGetError: true);
        await MessageRepo().fetchHiddenMessageCount(testUid, 0);
        verifyNever(seenDo.getMySeen(testUid.asString()));
        var s = await seenDo.getMySeen(testUid.asString());
        verifyNever(seenDo.saveMySeen(s.copy(
            newUid: testUid.asString(),
            newMessageId: 0,
            newHiddenMessageCount: 0)));
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
                json: DELETED_ROOM_MESSAGE,
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
            json: DELETED_ROOM_MESSAGE,
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
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterMessageDao(
            message: testMessage.copyWith(id: 1, json: EMPTY_MESSAGE));
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
              lastMessage:
                  testMessage.copyWith(id: 1, json: DELETED_ROOM_MESSAGE)),
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
            testMessage.copyWith(id: 1, json: DELETED_ROOM_MESSAGE));
      });
    });

    group('getLastMessageFromServer -', () {
      Message message = Message(
          roomUid: testUid.asString(),
          packetId: "",
          time: 0,
          id: 0,
          json: DELETED_ROOM_MESSAGE,
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
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(
              type: MessageType.TEXT,
              time: 946672200000,
              json: "{\"1\":\"test\"}"));

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
      test('When called should updateRoom', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final roomDao = getAndRegisterRoomDao();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendTextMessage(testUid, "test");
            verify(roomDao.updateRoom(Room(
                uid: pm.roomUid,
                lastMessage: pm.msg,
                lastMessageId: pm.msg.id,
                deleted: false,
                lastUpdateTime: pm.msg.time)));
          },
        );
      });
      test('When called should sendMessageToServer', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final coreServices = getAndRegisterCoreServices();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendTextMessage(testUid, "test");
            message_pb.MessageByClient byClient = message_pb.MessageByClient()
              ..packetId = pm.msg.packetId
              ..to = pm.msg.to.asUid()
              ..replyToId = Int64(pm.msg.replyToId)
              ..text = message_pb.Text.fromJson(pm.msg.json);
            verify(coreServices.sendMessage(byClient));
          },
        );
      });
    });
    group('sendLocationMessage -', () {
      Position testPosition = Position(
          altitude: 0,
          accuracy: 0,
          heading: 0,
          latitude: 0,
          longitude: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: DateTime(2000));
      PendingMessage pm = testPendingMessage.copyWith(
        msg: testPendingMessage.msg.copyWith(
            type: MessageType.LOCATION, json: "{\"1\":0.0,\"2\":0.0}"),
      );

      test('When called should savePendingMessage', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final messageDao = getAndRegisterMessageDao();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendLocationMessage(testPosition, testUid);
            verify(messageDao.savePendingMessage(pm));
          },
        );
      });
      test('When called should updateRoomLastMessage', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final roomDao = getAndRegisterRoomDao();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendLocationMessage(testPosition, testUid);
            verify(roomDao.updateRoom(Room(
                uid: pm.roomUid,
                lastMessage: pm.msg,
                lastMessageId: pm.msg.id,
                deleted: false,
                lastUpdateTime: pm.msg.time)));
          },
        );
      });
      test('When called should send LocationMessage to server', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final coreServices = getAndRegisterCoreServices();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendLocationMessage(testPosition, testUid);
            message_pb.MessageByClient byClient = message_pb.MessageByClient()
              ..packetId = pm.msg.packetId
              ..to = pm.msg.to.asUid()
              ..replyToId = Int64(pm.msg.replyToId)
              ..location = location_pb.Location.fromJson(pm.msg.json);
            verify(coreServices.sendMessage(byClient));
          },
        );
      });
    });
    group('sendMultipleFilesMessages -', () {
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(type: MessageType.FILE),
          status: SendingStatus.SENDING_FILE,
          failed: false);

      test('When called should initUploadProgress', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final fileRepo = getAndRegisterFileRepo();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendMultipleFilesMessages(
                testUid, [model.File("test", "test")],
                caption: "test");
            verify(fileRepo.initUploadProgress("946672200000000"));
          },
        );
      });
      test('When called should uploadClonedFile', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final fileRepo = getAndRegisterFileRepo();
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendMultipleFilesMessages(
                testUid, [model.File("test", "test")],
                caption: "test");
            verify(fileRepo.uploadClonedFile("946672200000000", "test",
                sendActivity: anyNamed("sendActivity")));
          },
        );
      });
      test('When called should savePending Multiple Message ghfg hfgh',
          () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            file_pb.File sendingFakeFile = file_pb.File()
              ..uuid = pm.packetId
              ..caption = "test"
              ..width = 0
              ..height = 0
              ..type = "application/octet-stream"
              ..size = Int64(0)
              ..name = "test"
              ..duration = 0;
            final messageDao = getAndRegisterMessageDao();
            await MessageRepo().sendMultipleFilesMessages(
                testUid, [model.File("test", "test")],
                caption: "test");
            verify(messageDao.savePendingMessage(pm.copyWith(
                msg: testPendingMessage.msg.copyWith(
                    type: MessageType.FILE,
                    json: sendingFakeFile.writeToJson()))));
          },
        );
      });
      test(
          'When called if sendFileToServerOfPendingMessage did not return null should sendMessageToServer',
          () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final coreServices = getAndRegisterCoreServices();
            getAndRegisterFileRepo(
                fileInfo: file_pb.File(
                    uuid: testUid.asString(), caption: "test", name: "test"));
            // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
            await MessageRepo().sendMultipleFilesMessages(
                testUid, [model.File("test", "test")],
                caption: "test");
            message_pb.MessageByClient byClient = message_pb.MessageByClient()
              ..packetId = pm.msg.packetId
              ..to = pm.msg.to.asUid()
              ..replyToId = Int64(pm.msg.replyToId)
              ..file = file_pb.File(
                  name: "test", caption: "test", uuid: testUid.asString());
            verify(coreServices.sendMessage(byClient));
          },
        );
      });
    });
    group('sendPendingMessages -', () {
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(
            type: MessageType.FILE,
            json:
                "{\"1\":\"946672200000000\",\"2\":\"4096\",\"3\":\"application/octet-stream\",\"4\":\"test\",\"5\":\"test\",\"6\":0,\"7\":0,\"8\":0.0}",
          ),
          status: SendingStatus.SENDING_FILE);
      test('When called should getAllPendingMessages', () async {
        final messageDao = getAndRegisterMessageDao();
        await MessageRepo().sendPendingMessages();
        verify(messageDao.getAllPendingMessages());
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and SendingStatus is SENDING_FILE should uploadClonedFile',
          () async {
        final fileRepo = getAndRegisterFileRepo();
        getAndRegisterMessageDao(allPendingMessage: pm);
        await MessageRepo().sendPendingMessages();
        verify(fileRepo.uploadClonedFile("946672200000000", "test",
            sendActivity: anyNamed("sendActivity")));
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and SendingStatus is SENDING_FILE and cloned file are not null should savePendingMessage',
          () async {
        getAndRegisterFileRepo(
            fileInfo: file_pb.File(
                uuid: testUid.asString(), caption: "test", name: "test"));
        final messageDao = getAndRegisterMessageDao(allPendingMessage: pm);
        await MessageRepo().sendPendingMessages();
        verify(messageDao.savePendingMessage(pm.copyWith(
            msg: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            status: SendingStatus.PENDING)));
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and SendingStatus is SENDING_FILE and cloned file are not null should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterFileRepo(
            fileInfo: file_pb.File(
                uuid: testUid.asString(), caption: "test", name: "test"));
        getAndRegisterMessageDao(allPendingMessage: pm);
        await MessageRepo().sendPendingMessages();
        verify(roomDao.updateRoom(Room(
            uid: pm.roomUid,
            lastMessage: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            lastMessageId: pm.msg.id,
            deleted: false,
            lastUpdateTime: pm.msg.time)));
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and SendingStatus is SENDING_FILE and cloned file are not null should sendMessageToServer',
          () async {
        final coreServices = getAndRegisterCoreServices();
        getAndRegisterFileRepo(
            fileInfo: file_pb.File(
                uuid: testUid.asString(), caption: "test", name: "test"));
        getAndRegisterMessageDao(allPendingMessage: pm);
        await MessageRepo().sendPendingMessages();
        message_pb.MessageByClient byClient = message_pb.MessageByClient()
          ..packetId = pm.msg.packetId
          ..to = pm.msg.to.asUid()
          ..replyToId = Int64(pm.msg.replyToId)
          ..file = file_pb.File(
              name: "test", caption: "test", uuid: testUid.asString());
        verify(coreServices.sendMessage(byClient));
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and cloned file are not null should never save anything',
          () async {
        final fileRepo = getAndRegisterFileRepo();
        final coreServices = getAndRegisterCoreServices();
        final roomDao = getAndRegisterRoomDao();
        final messageDao = getAndRegisterMessageDao();
        await MessageRepo().sendPendingMessages();
        message_pb.MessageByClient byClient = message_pb.MessageByClient()
          ..packetId = pm.msg.packetId
          ..to = pm.msg.to.asUid()
          ..replyToId = Int64(pm.msg.replyToId)
          ..file = file_pb.File(
              name: "test", caption: "test", uuid: testUid.asString());
        verifyNever(coreServices.sendMessage(byClient));
        verifyNever(roomDao.updateRoom(Room(
            uid: pm.roomUid,
            lastMessage: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            lastMessageId: pm.msg.id,
            deleted: false,
            lastUpdateTime: pm.msg.time)));
        verifyNever(messageDao.savePendingMessage(pm.copyWith(
            msg: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            status: SendingStatus.PENDING)));
        verifyNever(fileRepo.uploadClonedFile("946672200000000", "test",
            sendActivity: anyNamed("sendActivity")));
      });
      test(
          'When called should getAllPendingMessages and if there is no pending message should break',
          () async {
        final fileRepo = getAndRegisterFileRepo();
        final coreServices = getAndRegisterCoreServices();
        final roomDao = getAndRegisterRoomDao();
        final messageDao = getAndRegisterMessageDao(allPendingMessage: pm);
        await MessageRepo().sendPendingMessages();
        message_pb.MessageByClient byClient = message_pb.MessageByClient()
          ..packetId = pm.msg.packetId
          ..to = pm.msg.to.asUid()
          ..replyToId = Int64(pm.msg.replyToId)
          ..file = file_pb.File(
              name: "test", caption: "test", uuid: testUid.asString());
        verifyNever(coreServices.sendMessage(byClient));
        verifyNever(roomDao.updateRoom(Room(
            uid: pm.roomUid,
            lastMessage: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            lastMessageId: pm.msg.id,
            deleted: false,
            lastUpdateTime: pm.msg.time)));
        verifyNever(messageDao.savePendingMessage(pm.copyWith(
            msg: pm.msg.copyWith(
                json:
                    "{\"1\":\"0:3049987b-e15d-4288-97cd-42dbc6d73abd\",\"4\":\"test\",\"5\":\"test\"}"),
            status: SendingStatus.PENDING)));
        verify(fileRepo.uploadClonedFile("946672200000000", "test",
            sendActivity: anyNamed("sendActivity")));
      });
      test(
          'When called should getAllPendingMessages and if there is pending message and SendingStatus is PENDING should sendMessage pm To Server',
          () async {
        final coreServices = getAndRegisterCoreServices();
        getAndRegisterMessageDao(
            allPendingMessage: pm.copyWith(status: SendingStatus.PENDING));
        await MessageRepo().sendPendingMessages();
        message_pb.MessageByClient byClient = message_pb.MessageByClient()
          ..packetId = pm.msg.packetId
          ..to = pm.msg.to.asUid()
          ..replyToId = Int64(pm.msg.replyToId)
          ..file = file_pb.File(
              name: "test",
              caption: "test",
              uuid: pm.msg.packetId,
              size: Int64(4096),
              type: "application/octet-stream",
              width: 0,
              height: 0,
              duration: 0.0);
        verify(coreServices.sendMessage(byClient));
      });
    });
    group('sendSeen -', () {
      test('When called should getMySeen', () async {
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().sendSeen(0, testUid);
        verify(seenDo.getMySeen(testUid.asString()));
      });
      test(
          'When called should getMySeen and if seen.messageId < messageId should sendSeen coreServices',
          () async {
        getAndRegisterSeenDao();
        final coreServices = getAndRegisterCoreServices();
        await MessageRepo().sendSeen(2, testUid);
        verify(coreServices.sendSeen(seen_pb.SeenByClient()
          ..to = testUid
          ..id = Int64.parseInt(2.toString())));
      });
      test(
          'When called should getMySeen and if seen.messageId >= messageId should return',
          () async {
        getAndRegisterSeenDao(messageId: 2);
        final coreServices = getAndRegisterCoreServices();
        await MessageRepo().sendSeen(0, testUid);
        verifyNever(coreServices.sendSeen(seen_pb.SeenByClient()
          ..to = testUid
          ..id = Int64.parseInt(2.toString())));
      });
    });
    group('sendForwardedMessage -', () {
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(
        forwardedFrom: testUid.asString(),
      ));

      test('When called should savePendingMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
          final messageDao = getAndRegisterMessageDao();
          MessageRepo().sendForwardedMessage(testUid, [testMessage]);
          verify(messageDao.savePendingMessage(pm));
        });
      });
      test('When called should updateRoomLastMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao();
          // always clock.now => 2000-01-01 00:00:00 =====> 946672200000.
          MessageRepo().sendForwardedMessage(testUid, [testMessage]);
          verify(roomDao.updateRoom(Room(
              uid: pm.roomUid,
              lastMessage: pm.msg,
              lastMessageId: pm.msg.id,
              deleted: false,
              lastUpdateTime: pm.msg.time)));
        });
      });
      test('When called should sendMessageToServer', () async {
        withClock(
          Clock.fixed(DateTime(2000)),
          () async {
            final coreServices = getAndRegisterCoreServices();
            MessageRepo().sendForwardedMessage(testUid, [testMessage]);
            message_pb.MessageByClient byClient = message_pb.MessageByClient()
              ..packetId = pm.msg.packetId
              ..to = pm.msg.to.asUid()
              ..replyToId = Int64(pm.msg.replyToId)
              ..forwardFrom = testUid;
            verify(coreServices.sendMessage(byClient));
          },
        );
      });
    });
    group('getPage -', () {
      test('When called if element!.id == containsId should return message',
          () async {
        final messageDao = getAndRegisterMessageDao();
        var messages = await MessageRepo().getPage(0, testUid.asString(), 0, 0);
        expect(messages.first, testMessage.copyWith(id: 0));
        verify(messageDao.getMessagePage(testUid.asString(), 0));
      });
      //todo add test after adding test for getMessages
      // test('When called if element!.id == containsId should return message',
      //     () async {
      //   final messageDao = getAndRegisterMessageDao();
      //   var messages = await MessageRepo().getPage(0, testUid.asString(), 0, 0);
      //   expect(messages.first, testMessage.copyWith(id: 0));
      //   verify(messageDao.getMessagePage(testUid.asString(), 0));
      // });
    });
    group('getMessages -', () {
      test('When called should fetchMessages from queryServiceClient',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 0);
        verify(queryServiceClient.fetchMessages(FetchMessagesReq()
          ..roomUid = testUid
          ..pointer = Int64(0)
          ..type = FetchMessagesReq_Type.FORWARD_FETCH
          ..limit = 16));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if fetched message type is MucSpecificPersistentEvent_Issue.DELETED should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesPersistEvent: PersistentEvent(
                mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                    issue: MucSpecificPersistentEvent_Issue.DELETED)),
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 10);
        verify(roomDao.updateRoom(Room(uid: testMessage.from, deleted: true)));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if '
          'fetched message type is MucSpecificPersistentEvent_Issue.ADD_USER should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesPersistEvent: PersistentEvent(
                mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                    issue: MucSpecificPersistentEvent_Issue.ADD_USER)),
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 10);
        verify(roomDao.updateRoom(Room(uid: testMessage.from, deleted: false)));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if '
          'fetched message type is MucSpecificPersistentEvent_Issue.KICK_USER and assignee isSame Entity with currentUserUid should updateRoom ',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesPersistEvent: PersistentEvent(
                mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                    issue: MucSpecificPersistentEvent_Issue.KICK_USER,
                    assignee: testUid)),
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 10);
        verify(roomDao.updateRoom(Room(uid: testMessage.from, deleted: true)));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if fetched message type '
          'is MucSpecificPersistentEvent_Issue.AVATAR_CHANGED should fetchAvatar',
          () async {
        final avatarRepo = getAndRegisterAvatarRepo();
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesPersistEvent: PersistentEvent(
                mucSpecificPersistentEvent: MucSpecificPersistentEvent(
                    issue: MucSpecificPersistentEvent_Issue.AVATAR_CHANGED,
                    assignee: testUid)),
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 10);
        verify(avatarRepo.fetchAvatar(testMessage.from.asUid(), true));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if fetched message type '
          'is MessageManipulationPersistentEvent_Action.DELETED should getMessage and saveMessage',
          () async {
        final messageDao = getAndRegisterMessageDao(message: testMessage);
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesPersistEvent: PersistentEvent(
                messageManipulationPersistentEvent:
                    MessageManipulationPersistentEvent(
                        messageId: Int64(0),
                        action:
                            MessageManipulationPersistentEvent_Action.DELETED)),
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 10);
        var mes = await messageDao.getMessage(testUid.asString(), 0);
        verify(messageDao.getMessage(testUid.asString(), 0));
        verify(messageDao.saveMessage(mes!..json = EMPTY_MESSAGE));
      });
      test(
          'When called should fetchMessages from queryServiceClient and saveFetchMessages and if fetched message id  equal to lastMessageId should updateRoom',
          () async {
        final roomDao = getAndRegisterRoomDao();
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 16,
            fetchMessagesHasOptions: false,
            fetchMessagesId: 0,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo()
            .getMessages(testUid.asString(), 0, 16, Completer(), 0);
        verify(roomDao.updateRoom(Room(
            lastMessage: testMessage.copyWith(
                id: 0,
                forwardedFrom: testUid.asString(),
                json: EMPTY_MESSAGE,
                packetId: ""),
            uid: testUid.asString(),
            lastMessageId: 0)));
      });
    });
    group('getEditedMsg -', () {
      test('When called should fetchMessages from queryServiceClient',
          () async {
        final queryServiceClient = getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 1,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        await MessageRepo().getEditedMsg(testUid, 0);
        verify(queryServiceClient.fetchMessages(FetchMessagesReq()
          ..roomUid = testUid
          ..pointer = Int64(0)
          ..type = FetchMessagesReq_Type.FORWARD_FETCH
          ..limit = 1));
      });
      test('When called should getRoom', () async {
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 1,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        final roomDao =
            getAndRegisterRoomDao(rooms: [Room(uid: testUid.asString())]);
        await MessageRepo().getEditedMsg(testUid, 0);
        verify(roomDao.getRoom(testUid.asString()));
      });
      test('When called should updateRoom', () async {
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 1,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        final roomDao =
            getAndRegisterRoomDao(rooms: [Room(uid: testUid.asString())]);
        await MessageRepo().getEditedMsg(testUid, 0);
        verify(roomDao.updateRoom(
            Room(uid: testUid.asString()).copyWith(lastUpdatedMessageId: 0)));
      });
      test('When called if lastMessageId==id should updateRoom', () async {
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 1,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        final roomDao = getAndRegisterRoomDao(
            rooms: [Room(uid: testUid.asString(), lastMessageId: 0)]);
        await MessageRepo().getEditedMsg(testUid, 0);
        verify(roomDao.updateRoom(
            Room(uid: testUid.asString(), lastMessageId: 0).copyWith(
          lastMessage: testMessage.copyWith(
              id: 0,
              replyToId: 0,
              forwardedFrom: testUid.asString(),
              json: EMPTY_MESSAGE,
              packetId: ""),
        )));
      });
      test('When called if lastMessageId==id should never updateRoom with msg',
          () async {
        getAndRegisterQueryServiceClient(
            fetchMessagesLimit: 1,
            fetchMessagesHasOptions: false,
            fetchMessagesType: FetchMessagesReq_Type.FORWARD_FETCH);
        final roomDao = getAndRegisterRoomDao(
            rooms: [Room(uid: testUid.asString(), lastMessageId: 5)]);
        await MessageRepo().getEditedMsg(testUid, 0);
        verifyNever(roomDao.updateRoom(
            Room(uid: testUid.asString(), lastMessageId: 5).copyWith(
          lastMessage: testMessage.copyWith(
              id: 0,
              replyToId: 0,
              forwardedFrom: testUid.asString(),
              json: EMPTY_MESSAGE,
              packetId: ""),
        )));
      });
    });
    group('sendActivity -', () {
      test('When called if category is group or user should sendActivity',
          () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final coreServices = getAndRegisterCoreServices();
          MessageRepo().sendActivity(testUid, ActivityType.TYPING);
          ActivityByClient activityByClient = ActivityByClient()
            ..typeOfActivity = ActivityType.TYPING
            ..to = testUid;
          verify(
              coreServices.sendActivity(activityByClient, "946672200000000"));
        });
      });
    });
    group('sendFormResultMessage -', () {
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(
              type: MessageType.FORM_RESULT,
              json: "{\"2\":[{\"1\":\"test\",\"2\":\"test\"}]}"));
      test('When called should savePendingMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final messageDao = getAndRegisterMessageDao();
          MessageRepo()
              .sendFormResultMessage(testUid.asString(), {"test": "test"}, 0);
          verify(messageDao.savePendingMessage(pm));
        });
      });
      test('When called should updateRoomLastMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao();
          MessageRepo()
              .sendFormResultMessage(testUid.asString(), {"test": "test"}, 0);
          verify(roomDao.updateRoom(Room(
              uid: pm.roomUid,
              lastMessage: pm.msg,
              lastMessageId: pm.msg.id,
              deleted: false,
              lastUpdateTime: pm.msg.time)));
        });
      });
      test('When called should sendMessageToServer', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final coreServices = getAndRegisterCoreServices();
          MessageRepo()
              .sendFormResultMessage(testUid.asString(), {"test": "test"}, 0);
          message_pb.MessageByClient byClient = message_pb.MessageByClient()
            ..packetId = pm.msg.packetId
            ..to = pm.msg.to.asUid()
            ..replyToId = Int64(pm.msg.replyToId)
            ..formResult = FormResult.fromJson(pm.msg.json);
          verify(coreServices.sendMessage(byClient));
        });
      });
    });
    group('sendShareUidMessage -', () {
      PendingMessage pm = testPendingMessage.copyWith(
          msg: testPendingMessage.msg.copyWith(
              type: MessageType.SHARE_UID,
              json:
                  "{\"1\":{\"1\":0,\"2\":\"3049987b-e15d-4288-97cd-42dbc6d73abd\",\"3\":\"*\"}}"));
      test('When called should savePendingMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final messageDao = getAndRegisterMessageDao();
          MessageRepo()
              .sendShareUidMessage(testUid, message_pb.ShareUid(uid: testUid));
          verify(messageDao.savePendingMessage(pm));
        });
      });
      test('When called should updateRoomLastMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao();
          MessageRepo()
              .sendShareUidMessage(testUid, message_pb.ShareUid(uid: testUid));
          verify(roomDao.updateRoom(Room(
              uid: pm.roomUid,
              lastMessage: pm.msg,
              lastMessageId: pm.msg.id,
              deleted: false,
              lastUpdateTime: pm.msg.time)));
        });
      });
      test('When called should sendMessageToServer', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final coreServices = getAndRegisterCoreServices();
          MessageRepo()
              .sendShareUidMessage(testUid, message_pb.ShareUid(uid: testUid));
          message_pb.MessageByClient byClient = message_pb.MessageByClient()
            ..packetId = pm.msg.packetId
            ..to = pm.msg.to.asUid()
            ..replyToId = Int64(pm.msg.replyToId)
            ..shareUid = message_pb.ShareUid.fromJson(pm.msg.json);
          verify(coreServices.sendMessage(byClient));
        });
      });
    });
    group('sendPrivateMessageAccept -', () {
      PendingMessage pm = testPendingMessage.copyWith(
        msg: testPendingMessage.msg.copyWith(
            type: MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE,
            json: "{\"1\":2,\"2\":\"test\"}"),
      );
      test('When called should savePendingMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final messageDao = getAndRegisterMessageDao();
          MessageRepo()
              .sendPrivateMessageAccept(testUid, PrivateDataType.EMAIL, "test");
          verify(messageDao.savePendingMessage(pm));
        });
      });
      test('When called should updateRoomLastMessage', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final roomDao = getAndRegisterRoomDao();
          MessageRepo()
              .sendPrivateMessageAccept(testUid, PrivateDataType.EMAIL, "test");
          verify(roomDao.updateRoom(Room(
              uid: pm.roomUid,
              lastMessage: pm.msg,
              lastMessageId: pm.msg.id,
              deleted: false,
              lastUpdateTime: pm.msg.time)));
        });
      });
      test('When called should sendMessageToServer', () async {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final coreServices = getAndRegisterCoreServices();
          MessageRepo()
              .sendPrivateMessageAccept(testUid, PrivateDataType.EMAIL, "test");
          message_pb.MessageByClient byClient = message_pb.MessageByClient()
            ..packetId = pm.msg.packetId
            ..to = pm.msg.to.asUid()
            ..replyToId = Int64(pm.msg.replyToId)
            ..sharePrivateDataAcceptance =
                SharePrivateDataAcceptance.fromJson(pm.msg.json);
          verify(coreServices.sendMessage(byClient));
        });
      });
    });
    group('getMessage -', () {
      test('When called should getMessage', () async {
        final messageDao = getAndRegisterMessageDao(message: testMessage);
        MessageRepo().getMessage(testUid.asString(), 0);
        verify(messageDao.getMessage(testUid.asString(), 0));
        expect(await messageDao.getMessage(testUid.asString(), 0), testMessage);
      });
    });
    group('getPendingMessage -', () {
      test('When called should getPendingMessage', () async {
        final messageDao =
            getAndRegisterMessageDao(pendingMessage: testPendingMessage);
        MessageRepo().getPendingMessage("");
        verify(messageDao.getPendingMessage(""));
        expect(await messageDao.getPendingMessage(""), testPendingMessage);
      });
    });
    group('watchPendingMessage -', () {
      test('When called should watchPendingMessage', () async {
        final messageDao = getAndRegisterMessageDao();
        MessageRepo().watchPendingMessage("");
        verify(messageDao.watchPendingMessage(""));
        expect(
            await messageDao.watchPendingMessage("").first, testPendingMessage);
      });
    });
    group('watchPendingMessages -', () {
      test('When called should watchPendingMessages', () async {
        final messageDao = getAndRegisterMessageDao();
        MessageRepo().watchPendingMessages(testUid.asString());
        verify(messageDao.watchPendingMessages(testUid.asString()));
        expect(await messageDao.watchPendingMessages(testUid.asString()).first,
            [testPendingMessage]);
      });
    });
    group('watchPendingMessages -', () {
      test('When called should getPendingMessages', () async {
        final messageDao = getAndRegisterMessageDao();
        MessageRepo().getPendingMessages(testUid.asString());
        verify(messageDao.getPendingMessages(testUid.asString()));
        expect(await messageDao.getPendingMessages(testUid.asString()),
            [testPendingMessage]);
      });
    });
    group('resendMessage -', () {
      test('When called should getPendingMessage', () async {
        final messageDao =
            getAndRegisterMessageDao(pendingMessage: testPendingMessage);
        MessageRepo().resendMessage(testMessage.copyWith(packetId: ""));
        verify(messageDao.getPendingMessage(""));
      });
      test('When called should getPendingMessage and save and send it',
          () async {
        final roomDao = getAndRegisterRoomDao();
        final coreServices = getAndRegisterCoreServices();
        final messageDao =
            getAndRegisterMessageDao(pendingMessage: testPendingMessage);
        await MessageRepo().resendMessage(testMessage.copyWith(packetId: ""));
        verify(messageDao.savePendingMessage(testPendingMessage));
        verify(roomDao.updateRoom(Room(
            uid: testPendingMessage.roomUid,
            lastMessage: testPendingMessage.msg,
            lastMessageId: testPendingMessage.msg.id,
            deleted: false,
            lastUpdateTime: testPendingMessage.msg.time)));
        message_pb.MessageByClient byClient = message_pb.MessageByClient()
          ..packetId = testPendingMessage.msg.packetId
          ..to = testPendingMessage.msg.to.asUid()
          ..replyToId = Int64(testPendingMessage.msg.replyToId);
        verify(coreServices.sendMessage(byClient));
      });
    });
    group('deletePendingMessage -', () {
      test('When called should deletePendingMessage', () async {
        final messageDao = getAndRegisterMessageDao();
        MessageRepo().deletePendingMessage("");
        verify(messageDao.deletePendingMessage(""));
      });
    });
    group('pinMessage -', () {
      test('When called should pinMessage', () async {
        final mucServices =
            getAndRegisterMucServices(pinMessageGetError: false);
        await MessageRepo().pinMessage(testMessage);
        verify(mucServices.pinMessage(testMessage));
        expect(await MessageRepo().pinMessage(testMessage), true);
      });
      test('When called should pinMessage and if get error should return false',
          () async {
        final mucServices = getAndRegisterMucServices(pinMessageGetError: true);
        await MessageRepo().pinMessage(testMessage);
        verify(mucServices.pinMessage(testMessage));
        expect(await MessageRepo().pinMessage(testMessage), false);
      });
    });
    group('unpinMessage -', () {
      test('When called should unpinMessage', () async {
        final mucServices =
        getAndRegisterMucServices(pinMessageGetError: false);
        await MessageRepo().unpinMessage(testMessage);
        verify(mucServices.unpinMessage(testMessage));
        expect(await MessageRepo().unpinMessage(testMessage), true);
      });
      test('When called should unpinMessage and if get error should return false',
              () async {
            final mucServices = getAndRegisterMucServices(pinMessageGetError: true);
            await MessageRepo().unpinMessage(testMessage);
            verify(mucServices.unpinMessage(testMessage));
            expect(await MessageRepo().unpinMessage(testMessage), false);
          });
    });
  });
}
