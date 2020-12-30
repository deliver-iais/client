import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock_classes_definition.dart';
import '../test_setup.dart';

void main() {
  CoreServices coreServices;
  setUp(() {
    coreServicesTestSetup();
    coreServices = CoreServices();
  });
  group('CoreService/start-checker-timer', () {
    test('_responseChecked becomes true after 2 seconds', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var res = MockResponseStream<ServerPacket>();

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);
      coreServices.startCheckerTimer();
      await Future.delayed(Duration(seconds: 2));
      coreServices.responseChecked = true;
      await Future.delayed(Duration(seconds: 3));
      expect(coreServices.backoffTime, 4);
    });
    test('_responseChecked becomes true after 4 seconds', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var res = new MockResponseStream<ServerPacket>();

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);
      coreServices.startCheckerTimer();
      await Future.delayed(Duration(seconds: 4));
      expect(coreServices.backoffTime, 8);
    });
    test('_responseChecked becomes true after 5 seconds', () async {
      var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
      var res = MockResponseStream<ServerPacket>();

      when(mockGrpcCoreService.establishStream(any,
              options: anyNamed('options')))
          .thenAnswer((_) => res);
      coreServices.startCheckerTimer();
      expect(coreServices.backoffTime, 4);
      await Future.delayed(Duration(seconds: 5));
      coreServices.responseChecked = true;
      expect(coreServices.backoffTime, 8);
      await Future.delayed(Duration(seconds: 8));
      expect(coreServices.backoffTime, 8);
      res.add(ServerPacket());
      await Future.delayed(Duration(seconds: 2));
      expect(coreServices.backoffTime, 4);
    });
    // test(
    //     '_responseChecked becomes true after 2 seconds and becomes false after 4',
    //     () async {
    //   var mockGrpcCoreService = GetIt.I.get<CoreServiceClient>();
    //
    //   var res = MockResponseStream<ServerPacket>();
    //
    //   when(mockGrpcCoreService.establishStream(any,
    //           options: anyNamed('options')))
    //       .thenAnswer((_) => res);
    //   coreServices.startCheckerTimer();
    //   expect(coreServices.backoffTime, 4);
    //   await Future.delayed(Duration(seconds: 2));
    //   coreServices.responseChecked = true;
    //   await Future.delayed(Duration(seconds: 4));
    //   expect(coreServices.backoffTime, 4);
    //   coreServices.responseChecked = false;
    //   await Future.delayed(Duration(seconds: 3));
    //   expect(coreServices.backoffTime, 8);
    // });
  });
}
