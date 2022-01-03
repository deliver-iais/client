import 'package:deliver/repository/messageRepo.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../helper/test_helper.dart';

void main() {
  group('MessageRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('MessageRepo -', () {
      test(
          'When called should check if coreServices.connectionStatus is connected we should update',
          () async {
        final coreServices = getAndRegisterCoreServices();
        MessageRepo();
        verify(coreServices.connectionStatus);
      });
    });
  });
}
