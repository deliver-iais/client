import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:emojis/emojis.dart';
import 'package:get_it/get_it.dart';
import 'package:test/test.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'messageRepoTestSetup.dart';
import 'package:mockito/mockito.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  MessageRepo messageRepo;
  final messagesList = [Message(id: 0), Message(id: 1)];
  final messagesFromServer = [
    MessageProto.Message()..id = Int64(0),
    MessageProto.Message()..id = Int64(1)
  ];
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
  });
  group('messageRepo/saveFetchMessages', () {
    test('', () async {
      var messages = List.from(messagesList);
      var mockCoreServices = GetIt.I.get<CoreServices>();
      when(mockCoreServices.saveMessageInMessagesDB(any))
          .thenAnswer((_) => messages.removeAt(0));
      expect(await messageRepo.saveFetchMessages(messagesFromServer),
          messagesList);
    });
  });
}
