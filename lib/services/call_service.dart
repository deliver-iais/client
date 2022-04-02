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

  UserCallState get getUserCallState => _callState;

  set setUserCallState(UserCallState cs) => _callState = cs;

  bool get isCallNotification => _isCallNotification;

  set setCallNotification(bool cn) => _isCallNotification = cn;
}
