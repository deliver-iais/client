import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'messageRepoTestSetup.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';

void main() {
  MessageRepo messageRepo;
  String roomId;
  int page;
  int containsId = 2;
  final messagesList = [Message(id: 0), Message(id: 1)];
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
    messageRepo;
    roomId = randomUid().getString();
    page = 0;
  });
  group('MessageRepo/getPage', () {
    test('getPage/page is in completer', () {
      // _completer is  private
    });
    test('getPage/page is in messageDao', () async {
      var messages = messagesList;
      messages.add(Message(id: 2));
      var mockMessageDao = GetIt.I.get<MessageDao>();
      when(mockMessageDao.getPage(roomId, page))
          .thenAnswer((_) async => messages);
      expect(await messageRepo.getPage(page, roomId, containsId), messages);
    });
    test('getPage/page is not in database and completer', () async {
      var messages = messagesList;
      messages.add(Message(id: 2));
      var mockQueryServiceClient = MockQueryServiceClient();
      // when(mockQueryServiceClient..fetchMessages(
      //     FetchMessagesReq()
      //       ..roomUid = roomId.uid
      //       ..pointer = Int64(containsId)
      //       ..type = FetchMessagesReq_Type.BACKWARD_FETCH
      //       ..limit = pageSize,
      //     options: CallOptions(metadata: {
      //       'accessToken': await _accountRepo.getAccessToken()
      //     }));)
      //     .thenAnswer((_) async => messages);
      expect(await messageRepo.getPage(page, roomId, containsId), messages);
    });
  });
}
//completer has page
//completer doesnt have page but db have it
//completer and db dont have page so get from server
