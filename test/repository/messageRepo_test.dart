import 'package:deliver/box/room.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
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
          'When called should check if coreServices.connectionStatus is connected we should update',
          () async {
        final coreServices = getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        MessageRepo();

        //verify(logger.i('updating -----------------'));
        expect(
            MessageRepo().updatingStatus.value, TitleStatusConditions.Updating);
      });
      test(
          'When called should check if coreServices.connectionStatus is disconnected updatingStatus should be TitleStatusConditions.Disconnected',
          () async {
        final coreServices = getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Disconnected);
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
            .updateNewMuc("0:e9cdce3d-5528-4ea2-9698-c379617d0329".asUid(), 0);
        verifyNever(roomDao.updateRoom(Room(
          uid: "0:e9cdce3d-5528-4ea2-9698-c379617d0329",
          lastMessageId: 0,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch,
        )));
      });
    });

    group('updatingMessages -', () {

      test('When called should get', () async {
        final coreServices = getAndRegisterCoreServices(
            connectionStatus: ConnectionStatus.Connected);
        final queryServiceClient = getAndRegisterQueryServiceClient();
        // MessageRepo().updatingMessages();
        Iterable<RoomMetadata>? roomsMeta = {
          'roomUid': {'category': 'SYSTEM', 'node': 'Notification Service'},
          'lastMessageId': 20,
          'lastUpdate': 1641279570559
        } as Iterable<RoomMetadata>?;
        when(queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
          ..pointer = 0
          ..limit = 10))
            .thenAnswer((realInvocation) =>
            MockResponseFuture<GetAllUserRoomMetaRes>(
                GetAllUserRoomMetaRes(roomsMeta: roomsMeta)));
        verify(queryServiceClient.getAllUserRoomMeta(GetAllUserRoomMetaReq()
          ..pointer = 0
          ..limit = 10));
      });
      //
      // test('When called should get all room', () async {
      //   final sharedDao = getAndRegisterSharedDao();
      //   MessageRepo().updatingMessages();
      //   verify(sharedDao.get(SHARED_DAO_FETCH_ALL_ROOM));
      // });





    });


  });
}
