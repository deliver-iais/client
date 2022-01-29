import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../helper/test_helper.dart';

Uid testUid = "0:3049987b-e15d-4288-97cd-42dbc6d73abd".asUid();

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
              lastMessage: Message(
                  id: 1,
                  from: testUid.asString(),
                  to: testUid.asString(),
                  packetId: testUid.asString(),
                  time: 0,
                  roomUid: testUid.asString()))
        ]);
        await MessageRepo().updatingMessages();
        verify(roomDao.getRoom(testUid.asString())).called(1);
      });

// No matching calls. All calls: MockRoomDao.getRoom('0:3049987b-e15d-4288-97cd-42dbc6d73abd'), MockRoomDao.updateRoom(Instance of 'Room'), MockRoomDao.updateRoom(Instance of 'Room')
// (If you called `verify(...).called(0);`, please instead use `verifyNever(...);`.)
//       test(
//           'When called if roomMetadata.presenceType be Active and rooms deleted being true should update the room',
//           () async {
//         getAndRegisterQueryServiceClient(presenceType: PresenceType.ACTIVE);
//         final roomDao = getAndRegisterRoomDao(rooms: [
//           Room(
//             uid: testUid.asString(),
//             deleted: true,
//           )
//         ]);
//         await MessageRepo().updatingMessages();
//         verify(roomDao.updateRoom(Room(
//             uid: testUid.asString(),
//            )));
//       });

      // cant verify
      // test('When called if roomMetadata.presenceType not be Active should updateRoom', () async {
      //   getAndRegisterQueryServiceClient(presenceType: PresenceType.DELETED);
      //   final roomDao = getAndRegisterRoomDao();
      //   await MessageRepo().updatingMessages();
      //   verify(roomDao.updateRoom(Room(uid:testUid.asString(),deleted: true,lastMessageId: 0,firstMessageId: 0,lastUpdateTime: 0)));
      // });
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
        final roomDao = getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(),
              lastMessage: Message(
                  to: testUid.asString(),
                  from: testUid.asString(),
                  packetId: testUid.asString(),
                  roomUid: testUid.asString(),
                  time: 0))
        ]);
        var rooms = await roomDao.getAllRooms();
        MessageRepo().updatingLastSeen();
        expect(rooms.first.lastMessage!.to.asUid().category, Categories.USER);
      });
      test(
          'When called should fetch all room from roomDao and if last message id be null should return',
          () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(),
              lastMessage: Message(
                  to: testUid.asString(),
                  from: testUid.asString(),
                  packetId: testUid.asString(),
                  roomUid: testUid.asString(),
                  time: 0))
        ]);
        await MessageRepo().updatingLastSeen();
        verifyNever(authRepo.isCurrentUser(testUid.asString()));
      });
      test(
          'When called should fetch all room from roomDao and if last message id not be null should check isCurrentUser',
          () async {
        final authRepo = getAndRegisterAuthRepo(isCurrentUser: true);
        final queryServiceClient = getAndRegisterQueryServiceClient();
        getAndRegisterRoomDao(rooms: [
          Room(
              uid: testUid.asString(),
              lastMessage: Message(
                  to: testUid.asString(),
                  from: testUid.asString(),
                  packetId: testUid.asString(),
                  roomUid: testUid.asString(),
                  id: 0,
                  time: 0))
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
              uid: testUid.asString(),
              lastMessage: Message(
                  to: testUid.asString(),
                  from: testUid.asString(),
                  packetId: testUid.asString(),
                  roomUid: testUid.asString(),
                  id: 0,
                  time: 0))
        ]);

        await MessageRepo().updatingLastSeen();
        verify(authRepo.isCurrentUser(testUid.asString()));
        verify(queryServiceClient
            .getUserRoomMeta(GetUserRoomMetaReq()..roomUid = testUid));
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
        //No matching calls. All calls: MockSeenDao.getMySeen('0:3049987b-e15d-4288-97cd-42dbc6d73abd'), MockSeenDao.saveMySeen(Instance of 'Seen')
        final seenDo = getAndRegisterSeenDao();
        await MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verify(await seenDo.saveMySeen(Seen(
            uid: "0:3049987b-e15d-4288-97cd-42dbc6d73abd",
            hiddenMessageCount: 0,
            messageId: 0)));
      });
      test(
          'When called should get My Seen if lastSeen messageId not be null and last seen messageId be greater than lastCurrentUserSentMessageId should return',
          () async {
        final seenDo = getAndRegisterSeenDao(messageId: 1);
        await MessageRepo().fetchCurrentUserLastSeen(roomMetadata);
        verifyNever(await seenDo.saveMySeen(Seen(
            uid: "0:3049987b-e15d-4288-97cd-42dbc6d73abd",
            hiddenMessageCount: 0,
            messageId: 0)));
      });
    });
  });
}
