import 'dart:async';

import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';

class ModeChecker {
  BehaviorSubject<AppMode> _mode;
  Stream<AppMode> get appMode => _mode.stream;
  int checkInterval = 1;
  BehaviorSubject<bool> updating;

  checkServerConnectivity() async {}

  ModeChecker() {
    _mode = BehaviorSubject.seeded(AppMode.DISCONNECT);
    updating = BehaviorSubject.seeded(false);

//     (DataConnectionChecker()..checkInterval = Duration(seconds: checkInterval))
//         .onStatusChange
//         .listen((status) async {
//       switch (status) {
//         case DataConnectionStatus.connected:
//           _mode.add(AppMode.STABLE);
//           break;
//         case DataConnectionStatus.disconnected:
//           _mode.add(AppMode.DISCONNECT);
// //          if (checkInterval == 8)
// //            checkInterval = 1;
// //          else
// //            checkInterval = checkInterval + 1;
// //          break;
//       }
//     });
  }
}
