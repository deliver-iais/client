import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:mockito/mockito.dart';

import 'test_helper.dart';
import 'test_helper.mocks.dart';

class MockServicesDiscoveryRepo extends Mock implements ServicesDiscoveryRepo {
  late MockQueryServiceClient _queryServiceClient;

  @override
  MockQueryServiceClient get queryServiceClient => _queryServiceClient;

  set queryServiceClient(MockQueryServiceClient value) {
    _queryServiceClient = value;
  }

  MockServicesDiscoveryRepo() {
    _queryServiceClient = getMockQueryServicesClient();
  }
}
