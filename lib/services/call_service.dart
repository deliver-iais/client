import 'dart:async';

import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import 'package:rxdart/rxdart.dart';

import '../models/call_event_type.dart';

enum UserCallState {
  /// User in Group Call then he Can't join any User or Start Own Call
  // ignore: constant_identifier_names
  INGROUPCALL,

  /// User in User Call then he Can't join any Group or Start Own Call
  // ignore: constant_identifier_names
  INUSERCALL,

  /// User Out of Call then he Can join any Group or User Call or Start Own Call
  // ignore: constant_identifier_names
  NOCALL,
}

class CallService {

  final BehaviorSubject<CallEvents> callEvents =
  BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _callEvents =
  BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> groupCallEvents =
  BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _groupCallEvents =
  BehaviorSubject.seeded(CallEvents.none);

  CallService(){
    _callEvents.distinct().listen((event) {
      callEvents.add(event);
    });
    _groupCallEvents.distinct().listen((event) {
      groupCallEvents.add(event);
    });
  }

  void addCallEvent(CallEvents event){
    _callEvents.add(event);
  }

  void addGroupCallEvent(CallEvents event){
    _groupCallEvents.add(event);
  }

  UserCallState _callState = UserCallState.NOCALL;
  bool _isCallNotification = false;

  late StreamSubscription<dynamic> _streamSubscription;

  static const platform = const MethodChannel('screen_management');

  Future<void> _listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    _streamSubscription = ProximitySensor.events.listen((int event) {
      if(event > 0){
        //turn off screen
        _callTurnScreenOff();
      }else{
        //turn on screen
        _callTurnScreenOn();
      }
    });
  }

  Future<void> _callTurnScreenOff() async {
    try {
      await platform.invokeMethod('turnOff');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<void> _callTurnScreenOn() async {
    try {
      await platform.invokeMethod('trunOn');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  void initProximitySensor() {
    _listenSensor();
  }

  Future<void> disposeProximitySensor() async {
    await _streamSubscription.cancel();
  }

  UserCallState get getUserCallState => _callState;

  set setUserCallState(UserCallState cs) => _callState = cs;

  bool get isCallNotification => _isCallNotification;

  set setCallNotification(bool cn) => _isCallNotification = cn;
}
