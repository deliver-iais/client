import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:mockito/mockito.dart';

import 'test_helper.dart';
import 'test_helper.mocks.dart';

class MockServicesDiscoveryRepo extends Mock implements ServicesDiscoveryRepo {
  late MockQueryServiceClient _queryServiceClient;
  late MockAuthServiceClient _authServiceClient;

  @override
  MockAuthServiceClient get authServiceClient => _authServiceClient;

  set authServiceClient(MockAuthServiceClient value) {
    _authServiceClient = value;
  }

  @override
  MockQueryServiceClient get queryServiceClient => _queryServiceClient;

  set queryServiceClient(MockQueryServiceClient value) {
    _queryServiceClient = value;
  }

  MockServicesDiscoveryRepo() {
    _queryServiceClient = getMockQueryServicesClient();
    _authServiceClient = getMockAuthServiceClient();
  }
}
