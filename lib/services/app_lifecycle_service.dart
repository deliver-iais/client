import 'dart:async';
import 'dart:ui';

import 'package:deliver/shared/methods/platform.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

enum AppLifecycle {
  ACTIVE,
  PAUSE,
}

class AppLifecycleService {
  static const MethodChannel _channel = MethodChannel("screen_management");
  final BehaviorSubject<AppLifecycle> _state =
      BehaviorSubject.seeded(AppLifecycle.ACTIVE);

  bool get isActive => _state.value == AppLifecycle.ACTIVE;

  Stream<AppLifecycle> get lifecycleStream => _state.stream.distinct();

  void updateAppStateToPause() => _state.value = AppLifecycle.PAUSE;

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
            unawaited(_channel.invokeMethod("closeApp"));
          } else {
            _state.add(AppLifecycle.ACTIVE);
          }
        }
        return message;
      });
    }
  }
}
