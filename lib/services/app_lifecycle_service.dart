import 'dart:ui';

import 'package:deliver/shared/methods/platform.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

enum AppLifecycle {
  ACTIVE,
  PAUSE,
  RESUME,
}

class AppLifecycleService {
  final BehaviorSubject<AppLifecycle> _state =
      BehaviorSubject.seeded(AppLifecycle.ACTIVE);

  AppLifecycle getAppLiveCycle() => _state.value;

  void updateAppStateToPause() => _state.value = AppLifecycle.PAUSE;

  bool appIsActive() => _state.value == AppLifecycle.ACTIVE;

  Stream<AppLifecycle> watchAppAppLifecycle() => _state.stream;

  void startLifeCycListener() {
    if (isDesktopNative) {
      DesktopLifecycle.instance.isActive.addListener(() {
        if (DesktopLifecycle.instance.isActive.value) {
          _state.add(AppLifecycle.ACTIVE);
        } else {
          _state.add(AppLifecycle.PAUSE);
        }
      });
    } else {
      SystemChannels.lifecycle.setMessageHandler((message) async {
        if (message != null) {
          if (message == AppLifecycleState.resumed.toString()) {
            _state.add(AppLifecycle.ACTIVE);
          } else if (message == AppLifecycleState.inactive.toString()) {
            _state.add(AppLifecycle.PAUSE);
          } else if (message == AppLifecycleState.paused.toString()) {
            _state.add(AppLifecycle.PAUSE);
          } else {
            _state.add(AppLifecycle.ACTIVE);
          }
        }
        return message;
      });
    }
  }
}
