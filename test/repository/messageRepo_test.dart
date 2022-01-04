import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
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
  });
}
