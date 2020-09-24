import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class ModeChecker {
  StreamController<AppMode> mode;
  Stream<AppMode> get appMode => mode.stream;
  int checkInterval = 1;

  static ClientChannel _clientChannel = ClientChannel("172.16.111.189",
      port: 30100,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  CoreServiceClient _coreServiceClient = CoreServiceClient(_clientChannel);

  checkServerConnectivity() async {
    AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
    try {
      var resStream = _coreServiceClient.establishStream(null,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      checkInterval = 1;
      mode.add(AppMode.UPDATING);
    } catch (e) {
      if (await mode.stream.last == AppMode.STABLE) {
        await Future.delayed(Duration(seconds: 4));
        try {
          var resStream = _coreServiceClient.establishStream(null,
              options: CallOptions(metadata: {
                'accessToken': await _accountRepo.getAccessToken()
              }));
          checkInterval = 1;
          mode.add(AppMode.UPDATING);
        } catch (e) {
          checkInterval = checkInterval + 1; //??????
          mode.add(AppMode.CONNECTING);
        }
      }
      if (checkInterval == 8)
        checkInterval = 1;
      else
        checkInterval = checkInterval + 1;
      mode.add(AppMode.CONNECTING);
    }
  }

  ModeChecker() {
    mode = StreamController<AppMode>.broadcast();
    mode.add(AppMode.CONNECTING);
    (DataConnectionChecker()..checkInterval = Duration(seconds: checkInterval))
        .onStatusChange
        .listen((status) async {
      switch (status) {
        case DataConnectionStatus.connected:
          checkServerConnectivity();
          break;
        case DataConnectionStatus.disconnected:
          if (await mode.stream.last == AppMode.STABLE)
            await Future.delayed(Duration(seconds: 4));
          if (checkInterval == 8)
            checkInterval = 1;
          else
            checkInterval = checkInterval + 1;
          mode.add(AppMode.CONNECTING);
          break;
      }
    });
  }
}
