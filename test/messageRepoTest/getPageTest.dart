import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'messageRepoTestSetup.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:fixnum/fixnum.dart';

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
    roomId = randomUid().getString();
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
      var mockQueryServiceClient = MockQueryServiceClient();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messagesList);
      when(mockQueryServiceClient.fetchMessages(
        FetchMessagesReq()
          ..roomUid = roomId.uid
          ..pointer = Int64(containsId)
          ..type = FetchMessagesReq_Type.BACKWARD_FETCH
          ..limit = pageSize,
      )).thenAnswer((_) => Future<FetchMessagesRes>.value(
          FetchMessagesRes().getDefaultForField(0)));
      expect(await messageRepo.getPage(page, roomId, containsId), messages);
    });
    test(
        'getPage/page is not in database and completer and server throws exception',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockQueryServiceClient = MockQueryServiceClient();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messagesList);
      when(mockQueryServiceClient.fetchMessages(any)).thenAnswer((_) {
        throw Exception('Server does not answer');
      });
      expect(
          await messageRepo.getPage(page, roomId, containsId), throwsException);
    });
  });
}

//TODO
// server
