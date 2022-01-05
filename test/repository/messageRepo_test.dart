import 'package:deliver/box/room.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../helper/test_helper.dart';

void main() {
  group('MessageRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('MessageRepo -', () {
      test('When called should check coreServices.connectionStatus', () async {
        final coreServices = getAndRegisterCoreServices();
        MessageRepo();
        verify(coreServices.connectionStatus);
      });
      test(
          'When called should check if coreServices.connectionStatus is connected we should see updating log',
          () async {
        final logger = getAndRegisterLogger();
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        // ignore: await_only_futures
        await MessageRepo();
        verify(logger.i('updating -----------------'));
      });
      test(
          'When called should check if coreServices.connectionStatus is connected  updatingStatus should be TitleStatusConditions.Updating',
          () async {
        getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        expect(await MessageRepo().updatingStatus.value,
            TitleStatusConditions.Updating);
      });

      test(
          'When called should check if coreServices.connectionStatus is disconnected updatingStatus should be TitleStatusConditions.Disconnected',
          () async {
        MessageRepo();
        expect(MessageRepo().updatingStatus.value,
            TitleStatusConditions.Disconnected);
      });

      test(
          'When called should check if coreServices.connectionStatus is Connecting updatingStatus should be TitleStatusConditions.Connecting',
          () async {
        final coreServices = getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connecting);
        MessageRepo();
        verify(coreServices.connectionStatus);
        expect(MessageRepo().updatingStatus.value,
            TitleStatusConditions.Connecting);
      });
    });

    group('updateNewMuc -', () {
      test('When called should update roomDao', () async {
        final roomDao = getAndRegisterRoomDao();
        MessageRepo()
            .updateNewMuc("0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd".asUid(), 0);
        verifyNever(roomDao.updateRoom(Room(
          uid: "0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd",
          lastMessageId: 0,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
        )));
      });
    });

    group('updatingMessages -', () {
      test('When called should fetch all room from sharedDao', () async {
        final sharedDao = getAndRegisterSharedDao();
        MessageRepo().updatingMessages();
        verify(sharedDao.get(SHARED_DAO_FETCH_ALL_ROOM));
      });

      test('When called should get All UserRoomMeta', () async {
        final queryServiceClient = getAndRegisterQueryServiceClient();
        await MessageRepo().updatingMessages();
        verify(queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
          ..pointer = 0
          ..limit = 10));
      });
      test('When called should get room from roomDao', () async {
        final roomDao = getAndRegisterRoomDao();
        await MessageRepo().updatingMessages();
        verify(roomDao.getRoom("0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd"));
      });
    });
  });
}
