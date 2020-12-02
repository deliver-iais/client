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
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:moor/moor.dart';
import 'package:test/test.dart';
import 'package:fixnum/fixnum.dart';
import 'messageRepoTestSetup.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as MessageProto;

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

  group('messageRepo/sendTextMessage', () {
    test('sending text messages without replyId, forwardedFrom parameter',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          json: (MessageProto.Text()..text = 'Test').writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..text = MessageProto.Text.fromJson(message.json)
        ..replyToId = Int64(-1);
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
        return pendingMessage;
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      print(byClient);
      expect(mockAccountRepo.currentUserUid, userId);
      await messageRepo.sendTextMessage(roomId, 'Test');
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(1);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(2);
      verify(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5)).called(1);
      verify(mockCoreServices.sendMessage(byClient)).called(1);
    });
    test('sending text messages with replyId, without forwardedFrom parameter',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          replyToId: 1,
          json: (MessageProto.Text()..text = 'Test').writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..text = MessageProto.Text.fromJson(message.json)
        ..replyToId = Int64(1);
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
        return pendingMessage;
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendTextMessage(roomId, 'Test', replyId: 1);
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(2);
      verify(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(1);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(1);
      verify(mockCoreServices.sendMessage(byClient)).called(1);
    });
    test('sending text messages without replyId, with forwardedFrom parameter',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var forwardedFrom = randomUid();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          forwardedFrom: forwardedFrom.asString(),
          json: (MessageProto.Text()..text = 'Test').writeToJson());
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
      var byClient = MessageProto.MessageByClient()
        ..packetId = 'test'
        ..to = message.to.getUid()
        ..text = MessageProto.Text.fromJson(message.json)
        ..replyToId = Int64(-1)
        ..forwardFrom = message.forwardedFrom.getUid();
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
        return pendingMessage;
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      await messageRepo.sendTextMessage(roomId, 'Test');
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(1);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(2);
      verify(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5)).called(1);
      verify(mockCoreServices.sendMessage(byClient)).called(1);
    });
    test('not sending text messages when pendingMessage does not exist',
        () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var message = Message(
          roomId: roomId.asString(),
          dbId: 5,
          to: roomId.asString(),
          packetId: 'test',
          type: MessageType.TEXT,
          json: (MessageProto.Text()..text = 'Test').writeToJson());

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
        return null;
      });
      when(mockMessageDao.deleteMessage(any)).thenAnswer((_) async {
        return 0;
      });
      await messageRepo.sendTextMessage(roomId, 'Test');
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(1);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(1);
      verify(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5)).called(1);
      verify(mockMessageDao.deleteMessage(any)).called(1);
      verifyNever(mockCoreServices.sendMessage(any));
    });
    test('not sending text messages when message is not exist', () async {
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockPendingMessageDao = GetIt.I.get<PendingMessageDao>();
      var mockCoreServices = GetIt.I.get<CoreServices>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var pendingMessage = PendingMessage(
          messageDbId: 5,
          messagePacketId: 'test',
          roomId: roomId.asString(),
          remainingRetries: MAX_REMAINING_RETRIES,
          status: SendingStatus.PENDING);
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
        return null;
      });

      when(mockPendingMessageDao.getByMessageDbId(any))
          .thenAnswer((realInvocation) async {
        return pendingMessage;
      });
      when(mockCoreServices.sendMessage(any)).thenAnswer((_) {
        return 0;
      });
      when(mockPendingMessageDao.deletePendingMessage(any))
          .thenAnswer((_) async {
        return 0;
      });
      await messageRepo.sendTextMessage(roomId, 'Test');
      verify(mockMessageDao.insertMessageCompanion(any)).called(1);
      verify(mockPendingMessageDao.insertPendingMessage(any)).called(1);
      verify(mockMessageDao.getPendingMessage(5)).called(1);
      verify(mockPendingMessageDao.getByMessageDbId(any)).called(1);
      verify(mockRoomDao.updateRoomLastMessage(roomId.asString(), 5)).called(1);
      verify(mockPendingMessageDao.deletePendingMessage(any)).called(1);
      verifyNever(mockCoreServices.sendMessage(any));
    });
  });
}
