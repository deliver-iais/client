import 'package:deliver/box/dao/current_call_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../box/call_info.dart';

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

  final _currentCall = GetIt.I.get<CurrentCallInfoDao>();

  final BehaviorSubject<CallEvents> callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> groupCallEvents =
      BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _groupCallEvents =
      BehaviorSubject.seeded(CallEvents.none);

  CallService() {
    _callEvents.distinct().listen((event) {
      callEvents.add(event);
    });
    _groupCallEvents.distinct().listen((event) {
      groupCallEvents.add(event);
    });
  }

  void addCallEvent(CallEvents event) {
    _callEvents.add(event);
  }

  void addGroupCallEvent(CallEvents event) {
    _groupCallEvents.add(event);
  }

  Future<void> saveCallOnDb(CallInfo callInfo) async {
    await _currentCall.save(callInfo);
  }

  Future<void> removeCallFromDb() async {
    await _currentCall.remove();
  }

  UserCallState _callState = UserCallState.NOCALL;

  Uid _callOwner = Uid.getDefault();

  String _callId = "";

  UserCallState get getUserCallState => _callState;

  set setUserCallState(UserCallState cs) => _callState = cs;

  Uid get getCallOwner => _callOwner;

  set setCallOwner(Uid uid) => _callOwner = uid;

  String get getCallId => _callId;

  set setCallId(String callId) => _callId = callId;
}
