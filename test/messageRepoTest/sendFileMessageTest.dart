//insert to messageDao
//insert to pendingMessage
//updateRoomLastMessage

import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;

import '../test_setup.dart';

void main() {
  MessageRepo messageRepo;
  setUp(() {
    messageRepoTestSetup();
    messageRepo = MessageRepo();
    // roomId = randomUid().asString();
    // page = 0;
  });
  Uid roomId = randomUid();
  Uid userId = Uid.create()
    ..category = Categories.USER
    ..node = "john";

  group('messageRepo/sendFileMessage', () {
    test('sending image file without replyId, caption', () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockFileRepo = GetIt.I.get<FileRepo>();
      bool isPending = false;
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.FILE,
          json: (FileProto.File()..caption = "").writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var sendingFileMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.SENDING_FILE);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..file = FileProto.File.fromJson(message.json)
        ..replyToId = Int64(-1);

      when(mockFileRepo.uploadClonedFile(any, any))
          .thenAnswer((realInvocation) async => FileProto.File());
      when(mockAccountRepo.currentUserUid).thenReturn(userId);

      when(mockMessageDao.insertMessageCompanion(any)).thenAnswer((_) async {
        return 5;
      });
      when(mockPendingMessageDao.insertPendingMessage(any))
          .thenAnswer((_) async {
        return 2;
      });
      when(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5))
          .thenAnswer((_) async {
        return 3;
      });
      //sendMessageToServer
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        if (isPending) {
          return pendingMessage;
        } else {
          isPending = true;
          return sendingFileMessage;
        }
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendFileMessage(
          roomId, 'test/test-resources/testImage.jpg');
      expect(mockAccountRepo.currentUserUid, userId);
      verify(mockFileRepo.cloneFileInLocalDirectory(any, any, any)).called(1);
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(2);
      verify(mockPendingMessageDao.getByMessageDbId(5)).called(2);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(4);
      verify(mockCoreServices.sendMessage(any)).called(1);
    });
    test('sending image file with caption', () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockFileRepo = GetIt.I.get<FileRepo>();
      bool isPending = false;
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.FILE,
          json: (FileProto.File()..caption = 'test caption').writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var sendingFileMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.SENDING_FILE);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..file = FileProto.File.fromJson(message.json)
        ..replyToId = Int64(-1);

      when(mockFileRepo.uploadClonedFile(any, any))
          .thenAnswer((realInvocation) async => FileProto.File());
      when(mockAccountRepo.currentUserUid).thenReturn(userId);

      when(mockMessageDao.insertMessageCompanion(any)).thenAnswer((_) async {
        return 5;
      });
      when(mockPendingMessageDao.insertPendingMessage(any))
          .thenAnswer((_) async {
        return 2;
      });
      when(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5))
          .thenAnswer((_) async {
        return 3;
      });
      //sendMessageToServer
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        if (isPending) {
          return pendingMessage;
        } else {
          isPending = true;
          return sendingFileMessage;
        }
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendFileMessage(
          roomId, 'test/test-resources/testImage.jpg',
          caption: 'test caption');
      expect(mockAccountRepo.currentUserUid, userId);
      verify(mockFileRepo.cloneFileInLocalDirectory(any, any, any)).called(1);
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(2);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(2);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(4);
      verify(mockCoreServices.sendMessage(any)).called(1);
    });
    test('sending image file with replyId', () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockFileRepo = GetIt.I.get<FileRepo>();
      bool isPending = false;
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.FILE,
          replyToId: 1,
          json: (FileProto.File()..caption = "").writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var sendingFileMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.SENDING_FILE);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..file = FileProto.File.fromJson(message.json)
        ..replyToId = Int64(1);

      when(mockFileRepo.uploadClonedFile(any, any))
          .thenAnswer((realInvocation) async => FileProto.File());
      when(mockAccountRepo.currentUserUid).thenReturn(userId);

      when(mockMessageDao.insertMessageCompanion(any)).thenAnswer((_) async {
        return 5;
      });
      when(mockPendingMessageDao.insertPendingMessage(any))
          .thenAnswer((_) async {
        return 2;
      });
      when(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5))
          .thenAnswer((_) async {
        return 3;
      });
      //sendMessageToServer
      when(mockMessageDao.getPendingMessage(5)).thenAnswer((_) async {
        return message;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        if (isPending) {
          return pendingMessage;
        } else {
          isPending = true;
          return sendingFileMessage;
        }
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendFileMessage(
          roomId, 'test/test-resources/testImage.jpg',
          replyToId: 1);
      expect(mockAccountRepo.currentUserUid, userId);
      verify(mockFileRepo.cloneFileInLocalDirectory(any, any, any)).called(1);
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(2);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(2);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(4);
      verify(mockCoreServices.sendMessage(byClient)).called(1);
    });
  });
}
