import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/models/user_room_meta.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'messageRepoTestSetup.dart';

void main() {
  MessageRepo messageRepo;
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
    // roomId = randomUid().asString();
    // page = 0;
  });
  group('messageRepo/updating', () {
    test(
        'get 3 UserRoomMeta and fetchMessage return 1 message and 3 rooms is updated and saveMessageInMessagesDB is called 3 times',
        () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[2]
        ..lastMessageId = Int64(4));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 1);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[1].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[1].asString(), lastMessageId: 2);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[2].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[2].asString(), lastMessageId: 3);
      });
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));

      when(mockCoreServices.saveMessageInMessagesDB(any))
          .thenAnswer((realInvocation) async => Message(id: 4));

      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .called(3);
      verify(mockCoreServices.saveMessageInMessagesDB(any)).called(3);
    });
    test(
        'get 3 UserRoomMeta and fetchMessage return 2 message and 3 rooms is updated and saveMessageInMessagesDB is called 3 times',
        () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(4));

      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      mres.messages.add(MessageProto.Message()..id = Int64(5));
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 1);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[1].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[1].asString(), lastMessageId: 2);
      });
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));

      when(mockCoreServices
              .saveMessageInMessagesDB(MessageProto.Message()..id = Int64(4)))
          .thenAnswer((realInvocation) async => Message(id: 4, dbId: 3));

      when(mockCoreServices
              .saveMessageInMessagesDB(MessageProto.Message()..id = Int64(5)))
          .thenAnswer((realInvocation) async => Message(id: 5, dbId: 5));

      when(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: roomUids[0].asString(),
              lastMessageId: Value(5),
              lastMessageDbId: Value(5))))
          .thenAnswer((_) async {
        print('jbkb.kkjvbk');
        return 0;
      });
      when(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: roomUids[1].asString(),
              lastMessageId: Value(5),
              lastMessageDbId: Value(5))))
          .thenAnswer((_) async {
        return 0;
      });
      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .called(2);
      verify(mockCoreServices.saveMessageInMessagesDB(any)).called(4);
      verify(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: roomUids[0].asString(),
              lastMessageId: Value(5),
              lastMessageDbId: Value(5))))
          .called(1);
      verify(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: roomUids[1].asString(),
              lastMessageId: Value(5),
              lastMessageDbId: Value(5))))
          .called(1);
    });
    test('get 1 UserRoomMeta and fetchMessage return empty list', () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));

      var mres = FetchMessagesRes();
      print(mres.messages.length);
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 1);
      });
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));

      when(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
              roomId: roomUids[0].asString(),
              lastMessageId: Value(5),
              lastMessageDbId: Value(5))))
          .thenAnswer((_) async {
        return 0;
      });

      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .called(1);
      verifyNever(mockCoreServices.saveMessageInMessagesDB(any));
      verifyNever(mockRoomDao.insertRoomCompanion(RoomsCompanion.insert(
          roomId: roomUids[0].asString(),
          lastMessageId: Value(5),
          lastMessageDbId: Value(5))));
    });
    test('get 3 UserRoomMeta and rooms dont need to be update', () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(1));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(1));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[2]
        ..lastMessageId = Int64(3));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 1);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[1].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[1].asString(), lastMessageId: 2);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[2].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[2].asString(), lastMessageId: 3);
      });
      // when(mockQueryServiceClient.fetchMessages(any,
      //         options: anyNamed('options')))
      //     .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));
      //
      // when(mockCoreServices.saveMessageInMessagesDB(any))
      //     .thenAnswer((realInvocation) async => Message(id: 4));

      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockRoomDao.getByRoomIdFuture(roomUids[0].asString())).called(1);
      verify(mockRoomDao.getByRoomIdFuture(roomUids[1].asString())).called(1);
      verify(mockRoomDao.getByRoomIdFuture(roomUids[2].asString())).called(1);
      verifyNever(mockQueryServiceClient.fetchMessages(any,
          options: anyNamed('options')));
      verifyNever(mockCoreServices.saveMessageInMessagesDB(any));
    });
    test(
        'get 4 UserRoomMeta and fetchMessage return 1 message and 3 rooms is not updated and one room added and saveMessageInMessagesDB is called 1 times',
        () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[2]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[3]
        ..lastMessageId = Int64(1));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 4);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[1].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[1].asString(), lastMessageId: 4);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[2].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[2].asString(), lastMessageId: 4);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[3].asString()))
          .thenAnswer((_) async {
        return null;
      });
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));

      when(mockCoreServices.saveMessageInMessagesDB(any))
          .thenAnswer((realInvocation) async => Message(id: 1));

      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .called(1);

      verify(mockCoreServices.saveMessageInMessagesDB(any)).called(1);
    });
    test('getAllUserRoomMeta throws exception', () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[2]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[3]
        ..lastMessageId = Int64(1));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenThrow(MockResponseFuture<Exception>(
              Exception('getAllUserRoomMeta throws exception')));

      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
    });
    test('fetchMessage throws exception for one room', () async {
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var res = GetAllUserRoomMetaRes();
      var roomUids = [randomUid(), randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[0]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[1]
        ..lastMessageId = Int64(4));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomUids[2]
        ..lastMessageId = Int64(4));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<GetAllUserRoomMetaRes>(res));

      when(mockRoomDao.getByRoomIdFuture(roomUids[0].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[0].asString(), lastMessageId: 1);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[1].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[1].asString(), lastMessageId: 2);
      });
      when(mockRoomDao.getByRoomIdFuture(roomUids[2].asString()))
          .thenAnswer((_) async {
        return Room(roomId: roomUids[2].asString(), lastMessageId: 3);
      });
      when(mockQueryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = roomUids[0]
                ..pointer = Int64(4)
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = 2,
              options: anyNamed('options')))
          .thenThrow(MockResponseFuture<Exception>(
              Exception('fetchMessage throws exception')));
      when(mockQueryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = roomUids[1]
                ..pointer = Int64(4)
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = 2,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));
      when(mockQueryServiceClient.fetchMessages(
              FetchMessagesReq()
                ..roomUid = roomUids[2]
                ..pointer = Int64(4)
                ..type = FetchMessagesReq_Type.FORWARD_FETCH
                ..limit = 2,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(mres));
      when(mockCoreServices.saveMessageInMessagesDB(any))
          .thenAnswer((realInvocation) async => Message(id: 4));
      await messageRepo.updating();
      verify(mockQueryServiceClient.getAllUserRoomMeta(any,
              options: anyNamed('options')))
          .called(1);
      verify(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .called(3);
      verify(mockCoreServices.saveMessageInMessagesDB(any)).called(2);
    });
  });
}
