import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'messageRepoTestSetup.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;

void main() {
  MessageRepo messageRepo;
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
    // roomId = randomUid().asString();
    // page = 0;
  });
  var roomId = randomUid();
  // var userId = Uid.create()
  //   ..category = Categories.USER
  //   ..node = "john";

  group('messageRepo/sendPendingMessage', () {
    test('sending pending message with pending status with remainingTry > 0',
        () async {
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          replyToId: 1,
          json: (MessageProto.Text()..text = 'Test').writeToJson());
      var pendingMessages = [
        PendingMessage(
            messageDbId: 5,
            messagePacketId: 'test',
            roomId: roomId.asString(),
            remainingRetries: MAX_REMAINING_RETRIES,
            status: SendingStatus.PENDING),
      ];
      when(mockPendingMessageDao.getAllPendingMessages())
          .thenAnswer((realInvocation) async => pendingMessages);
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        return pendingMessages[0];
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendPendingMessages();
      verify(mockCoreServices.sendMessage(any)).called(1);
    });
    test('sending pending message with pending status with remainingTry = 0',
        () async {
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          replyToId: 1,
          json: (MessageProto.Text()..text = 'Test').writeToJson());
      var pendingMessages = [
        PendingMessage(
            messageDbId: 5,
            messagePacketId: 'test',
            roomId: roomId.asString(),
            remainingRetries: 0,
            status: SendingStatus.PENDING),
      ];
      when(mockPendingMessageDao.getAllPendingMessages())
          .thenAnswer((realInvocation) async => pendingMessages);
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        return pendingMessages[0];
      });
      when(mockMessageDao.deleteMessage(any)).thenAnswer((_) async {
        return 0;
      });
      when(mockPendingMessageDao.deletePendingMessage(any))
          .thenAnswer((realInvocation) async {
        return 0;
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendPendingMessages();
      verify(mockMessageDao.deleteMessage(any)).called(1);
      verify(mockPendingMessageDao.deletePendingMessage(any)).called(1);
      verifyNever(mockCoreServices.sendMessage(any));
    });
    test(
        'sending pending message with sendingFile status with remainingTry > 0',
        () async {
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockFileRepo = GetIt.I.get<FileRepo>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.FILE,
          replyToId: 1,
          json: (FileProto.File()
                ..name = 'test.png'
                ..caption = 'Test caption')
              .writeToJson());
      var pendingMessages = [
        PendingMessage(
            messageDbId: 5,
            messagePacketId: 'test',
            roomId: roomId.asString(),
            remainingRetries: MAX_REMAINING_RETRIES,
            status: SendingStatus.SENDING_FILE),
      ];

      when(mockPendingMessageDao.getAllPendingMessages())
          .thenAnswer((realInvocation) async => pendingMessages);

      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        return pendingMessages[0];
      });

      when(mockFileRepo.uploadClonedFile(any, any))
          .thenAnswer((realInvocation) async {
        return FileProto.File();
      });

      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });

      when(mockMessageDao.updateMessageTimeAndJson(any, any, any))
          .thenAnswer((realInvocation) async => 2);

      when(mockPendingMessageDao.insertPendingMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.updateRoomLastMessage(any, any))
          .thenAnswer((realInvocation) async => 5);

      await messageRepo.sendPendingMessages();
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(2);
      verify(mockFileRepo.uploadClonedFile(any, any)).called(1);
      verify(mockMessageDao.updateMessageTimeAndJson(any, any, any)).called(1);
      verify(mockRoomDao.updateRoomLastMessage(any, any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(3);
    });
    test(
        'sending pending message with sendingFile status with remainingTry < 0',
        () async {
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockFileRepo = GetIt.I.get<FileRepo>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.FILE,
          replyToId: 1,
          json: (FileProto.File()
                ..name = 'test.png'
                ..caption = 'Test caption')
              .writeToJson());
      var pendingMessages = [
        PendingMessage(
            messageDbId: 5,
            messagePacketId: 'test',
            roomId: roomId.asString(),
            remainingRetries: 0,
            status: SendingStatus.SENDING_FILE),
      ];
      bool isDeleted = false;
      when(mockPendingMessageDao.getAllPendingMessages())
          .thenAnswer((realInvocation) async => pendingMessages);
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        if (isDeleted) return null;
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        if (isDeleted) return null;
        return pendingMessages[0];
      });
      when(mockMessageDao.deleteMessage(any)).thenAnswer((_) async {
        isDeleted = true;
        return 0;
      });
      when(mockPendingMessageDao.deletePendingMessage(any))
          .thenAnswer((realInvocation) async {
        return 0;
      });
      await messageRepo.sendPendingMessages();
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(2);
      verifyNever(mockFileRepo.uploadClonedFile(any, any));
      verifyNever(mockMessageDao.updateMessageTimeAndJson(any, any, any));
      verifyNever(mockRoomDao.updateRoomLastMessage(any, any));
      verifyNever(mockPendingMessageDao.insertPendingMessage(any));
      verify(mockMessageDao.deleteMessage(any)).called(1);
      verify(mockPendingMessageDao.deletePendingMessage(any)).called(1);
    });
  });
}
