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
import 'package:grpc/grpc.dart';
import 'package:mockito/mockito.dart';
import 'package:random_string/random_string.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:fixnum/fixnum.dart';

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
      var roomIds = [randomUid(), randomUid(), randomUid()];
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomIds[0]
        ..lastMessageId = Int64(2));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomIds[0]
        ..lastMessageId = Int64(1));
      res.roomsMeta.add(UserRoomMeta()
        ..roomUid = roomIds[0]
        ..lastMessageId = Int64(3));
      var mres = FetchMessagesRes();
      mres.messages.add(MessageProto.Message()..id = Int64(4));
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      print('res in test $res');
      when(mockAccountRepo.getAccessToken()).thenAnswer((_) async {
        return 'expected';
      });
      when(mockQueryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq(),
          options: CallOptions(metadata: {
            'accessToken': await mockAccountRepo.getAccessToken()
          }))).thenAnswer((_) {
        print('common please');
        return Future.value(res);
      });

      when(mockRoomDao.getByRoomIdFuture(any)).thenAnswer((_) async {
        return Room(roomId: any, lastMessageId: 4);
      });

      when(await mockQueryServiceClient.fetchMessages(any)).thenReturn(mres);

      when(mockCoreServices.saveMessageInMessagesDB(any))
          .thenAnswer((realInvocation) async => Message(id: 4));

      await messageRepo.updating();
      // verify(mockAccountRepo.getAccessToken()).called(1);
      verify(mockQueryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq(),
          options: CallOptions(metadata: {
            'accessToken': await mockAccountRepo.getAccessToken()
          }))).called(1);
      print('ttttttttttttttt');
      // verify(mockQueryServiceClient.fetchMessages(any)).called(3);
      // verify(mockAccountRepo.getAccessToken()).called(1);
      // verify(mockCoreServices.saveMessageInMessagesDB(any)).called(3);
    });
    // test(
    //     'get 3 UserRoomMeta and fetchMessage return 2 message and 3 rooms is updated and  saveMessageInMessagesDB is called 6 times',
    //     () async {
    //   var mockCoreServices = GetIt.I.get<CoreServices>();
    //   var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
    //   var mockRoomDao = GetIt.I.get<RoomDao>();
    //   var res = GetAllUserRoomMetaRes();
    //
    //   var roomIds = [randomUid(), randomUid(), randomUid()];
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(2));
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(3));
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(1));
    //   var mres = FetchMessagesRes();
    //   mres.messages.add(MessageProto.Message()..id = Int64(4));
    //
    //   when(await mockQueryServiceClient.getAllUserRoomMeta(any))
    //       .thenReturn(res);
    //   when(mockRoomDao.getByRoomIdFuture(any)).thenAnswer((_) async {
    //     return Room(roomId: any, lastMessageId: 4);
    //   });
    //   when(await mockQueryServiceClient.fetchMessages(any)).thenReturn(mres);
    //   expect(messageRepo.updating(), throwsException);
    // });
    // test(
    //     'get 3 UserRoomMeta and fetchMessage return 1 message and rooms is not updated and  saveMessageInMessagesDB is not called',
    //     () async {
    //   var mockCoreServices = GetIt.I.get<CoreServices>();
    //   var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
    //   var mockRoomDao = GetIt.I.get<RoomDao>();
    //   var res = GetAllUserRoomMetaRes();
    //   var roomIds = [randomUid(), randomUid(), randomUid()];
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(5));
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(3));
    //   res.roomsMeta.add(UserRoomMeta()
    //     ..roomUid = roomIds[0]
    //     ..lastMessageId = Int64(8));
    //   var mres = FetchMessagesRes();
    //   mres.messages.add(MessageProto.Message()..id = Int64(4));
    //   when(await mockQueryServiceClient.getAllUserRoomMeta(any))
    //       .thenReturn(res);
    //   when(mockRoomDao.getByRoomIdFuture(any)).thenAnswer((_) async {
    //     return Room(roomId: any, lastMessageId: 2);
    //   });
    //   when(await mockQueryServiceClient.fetchMessages(any)).thenReturn(mres);
    //   expect(messageRepo.updating(), throwsException);
    // });
    // test('description', () async {
    //   var mockCoreServices = GetIt.I.get<CoreServices>();
    //   var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
    //   when(await mockQueryServiceClient.getAllUserRoomMeta(any))
    //       .thenAnswer((realInvocation) {
    //     throw Future.value(Exception);
    //   });
    //   expect(messageRepo.updating(), throwsException);
    // });
  });
}
