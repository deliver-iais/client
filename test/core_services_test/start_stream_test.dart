import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/shared/methods/helper.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:mockito/mockito.dart';
import 'package:fixnum/fixnum.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';

import '../mock_classes_definition.dart';
import '../test_setup.dart';

void main() {
  CoreServices coreServices;
  Uid currentUserId = Uid.create()
    ..category = Categories.USER
    ..node = "john";
  Uid userId = Uid.create()
    ..category = Categories.USER
    ..node = "joe";
  Uid groupId = Uid.create()
    ..category = Categories.GROUP
    ..node = "5745645454545456";
  setUp(() {
    coreServicesTestSetup();
    coreServices = CoreServices();
  });

  group('CoreServices/startStream', () {
    test('serverPacket has message from current user to another user',
        () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockNotificationServices = GetIt.I.get<NotificationServices>();
      var mockRoomRepo = GetIt.I.get<RoomRepo>();
      var serverPacket = ServerPacket()
        ..message = (Message()
          ..from = currentUserId
          ..to = userId
          ..id = Int64(2)
          ..packetId = 'test'
          ..replyToId = Int64(0)
          ..text = (Text()..text = 'test'));

      var res = MockResponseStream<ServerPacket>();

      when(mockAccountRepo.currentUserUid).thenReturn(currentUserId);

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);

      when(mockMessageDao.insertMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.insertRoomCompanion(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomRepo.getName(userId))
          .thenAnswer((_) async => "name");

      when(mockNotificationServices.showNotification(any, any, any))
          .thenAnswer((_) {});

      await coreServices.startStream();
      res.add(serverPacket);
      await Future.delayed(Duration(seconds: 2));
      verify(mockMessageDao.insertMessage(any)).called(1);
      verify(mockRoomRepo.getName(userId)).called(1);
      verify(mockNotificationServices.showNotification(any, any, any))
          .called(1);
    });
    test('serverPacket has message from another user to current user',
        () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockNotificationServices = GetIt.I.get<NotificationServices>();
      var mockRoomRepo = GetIt.I.get<RoomRepo>();
      var serverPacket = ServerPacket()
        ..message = (Message()
          ..from = userId
          ..to = currentUserId
          ..id = Int64(2)
          ..packetId = 'test'
          ..replyToId = Int64(0)
          ..text = (Text()..text = 'test'));

      var res = MockResponseStream<ServerPacket>();

      when(mockAccountRepo.currentUserUid).thenReturn(currentUserId);

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);

      when(mockMessageDao.insertMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.insertRoomCompanion(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomRepo.getName(userId))
          .thenAnswer((_) async => "name");

      when(mockNotificationServices.showNotification(any, any, any))
          .thenAnswer((_) {});

      await coreServices.startStream();
      res.add(serverPacket);
      await Future.delayed(Duration(seconds: 2));
      verify(mockMessageDao.insertMessage(any)).called(1);
      verify(mockRoomRepo.getName(userId)).called(1);
      verify(mockNotificationServices.showNotification(any, any, any))
          .called(1);
    });
    test('serverPacket has message from group to current user', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockNotificationServices = GetIt.I.get<NotificationServices>();
      var mockRoomRepo = GetIt.I.get<RoomRepo>();
      var serverPacket = ServerPacket()
        ..message = (Message()
          ..from = userId
          ..to = groupId
          ..id = Int64(2)
          ..packetId = 'test'
          ..replyToId = Int64(0)
          ..text = (Text()..text = 'test'));

      var res = MockResponseStream<ServerPacket>();

      when(mockAccountRepo.currentUserUid).thenReturn(currentUserId);

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);

      when(mockMessageDao.insertMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.insertRoomCompanion(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomRepo.getName(groupId))
          .thenAnswer((_) async => "name");

      when(mockNotificationServices.showNotification(any, any, any))
          .thenAnswer((_) {});

      await coreServices.startStream();
      res.add(serverPacket);
      await Future.delayed(Duration(seconds: 2));
      verify(mockMessageDao.insertMessage(any)).called(1);
      verify(mockRoomRepo.getName(groupId)).called(1);
      verify(mockNotificationServices.showNotification(any, any, any))
          .called(1);
    });
    test('serverPacket has message from current user to a group', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockNotificationServices = GetIt.I.get<NotificationServices>();
      var mockRoomRepo = GetIt.I.get<RoomRepo>();
      var serverPacket = ServerPacket()
        ..message = (Message()
          ..from = currentUserId
          ..to = groupId
          ..id = Int64(2)
          ..packetId = 'test'
          ..replyToId = Int64(0)
          ..text = (Text()..text = 'test'));

      var res = MockResponseStream<ServerPacket>();

      when(mockAccountRepo.currentUserUid).thenReturn(currentUserId);

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);

      when(mockMessageDao.insertMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.insertRoomCompanion(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomRepo.getName(groupId))
          .thenAnswer((_) async => "name");

      when(mockNotificationServices.showNotification(any, any, any))
          .thenAnswer((_) {});

      await coreServices.startStream();
      res.add(serverPacket);
      await Future.delayed(Duration(seconds: 2));
      verify(mockMessageDao.insertMessage(any)).called(1);
      verify(mockRoomRepo.getName(groupId)).called(1);
      verify(mockNotificationServices.showNotification(any, any, any))
          .called(1);
    });
    test('serverPacket has message from a user to group', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var mockAccountRepo = GetIt.I.get<AccountRepo>();
      var mockMessageDao = GetIt.I.get<MessageDao>();
      var mockRoomDao = GetIt.I.get<RoomDao>();
      var mockNotificationServices = GetIt.I.get<NotificationServices>();
      var mockRoomRepo = GetIt.I.get<RoomRepo>();
      var serverPacket = ServerPacket()
        ..message = (Message()
          ..from = userId
          ..to = groupId
          ..id = Int64(2)
          ..packetId = 'test'
          ..replyToId = Int64(0)
          ..text = (Text()..text = 'test'));

      var res = MockResponseStream<ServerPacket>();

      when(mockAccountRepo.currentUserUid).thenReturn(currentUserId);

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);

      when(mockMessageDao.insertMessage(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomDao.insertRoomCompanion(any))
          .thenAnswer((realInvocation) async => 5);

      when(mockRoomRepo.getName(groupId))
          .thenAnswer((_) async => "name");

      when(mockNotificationServices.showNotification(any, any, any))
          .thenAnswer((_) {});

      await coreServices.startStream();
      res.add(serverPacket);
      await Future.delayed(Duration(seconds: 2));
      verify(mockMessageDao.insertMessage(any)).called(1);
      verify(mockRoomRepo.getName(groupId)).called(1);
      verify(mockNotificationServices.showNotification(any, any, any))
          .called(1);
    });
  });
}
