import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'messageRepoTestSetup.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;

void main() {
  MessageRepo messageRepo;
  String roomId;
  int page;
  int containsId = 2;
  int pageSize = 3;
  final messagesList = [Message(id: 0), Message(id: 1)];
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
    roomId = randomUid().asString();
    page = 0;
  });
  group('MessageRepo/getPage', () {
    test('getPage/page is in messageDao', () async {
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      var mockMessageDao = GetIt.I.get<MessageDao>();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messages);
      expect(await messageRepo.getPage(page, roomId, containsId), messages);
    });

    test('getPage/page is not in database and completer', () async {
      final messages = [Message(id: 0), Message(id: 1), Message(id: 2)];
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messagesList);
      FetchMessagesRes res = FetchMessagesRes();
      res.messages.add(MessageProto.Message()..id = Int64(0));
      res.messages.add(MessageProto.Message()..id = Int64(1));
      res.messages.add(MessageProto.Message()..id = Int64(2));
      print(res.messages);
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenAnswer((_) => MockResponseFuture<FetchMessagesRes>(res));
      when(mockCoreServices
              .saveMessageInMessagesDB(MessageProto.Message()..id = Int64(0)))
          .thenAnswer((realInvocation) async => Message(id: 0));
      when(mockCoreServices
              .saveMessageInMessagesDB(MessageProto.Message()..id = Int64(1)))
          .thenAnswer((realInvocation) async => Message(id: 1));
      when(mockCoreServices
              .saveMessageInMessagesDB(MessageProto.Message()..id = Int64(2)))
          .thenAnswer((realInvocation) async => Message(id: 2));
      expect(await messageRepo.getPage(page, roomId, containsId), messages);
    });
    test(
        'getPage/page is not in database and completer and server throws exception',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockQueryServiceClient = GetIt.I.get<QueryServiceClient>();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messagesList);
      when(mockQueryServiceClient.fetchMessages(any,
              options: anyNamed('options')))
          .thenThrow(MockResponseFuture<Exception>(
              Exception('fetchMessage throws exception')));
      bool error = false;
      await messageRepo.getPage(page, roomId, containsId).catchError((e) {
        error = true;
      });
      expect(error, true);
    });
  });
}
