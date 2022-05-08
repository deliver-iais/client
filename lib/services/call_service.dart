import 'package:deliver/models/call_event_type.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:rxdart/rxdart.dart';
import 'package:deliver/box/call_status.dart' as call_status;
import 'package:deliver/box/call_type.dart';


import '../box/call_status.dart';

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

  UserCallState _callState = UserCallState.NOCALL;

  Uid _callOwner = Uid.getDefault();

  String _callId = "";

  UserCallState get getUserCallState => _callState;

  set setUserCallState(UserCallState cs) => _callState = cs;

  Uid get getCallOwner => _callOwner;

  set setCallOwner(Uid uid) => _callOwner = uid;

  String get getCallId => _callId;

  set setCallId(String callId) => _callId = callId;


  call_status.CallStatus findCallEventStatusProto(
      CallEvent_CallStatus eventCallStatus,
      ) {
    switch (eventCallStatus) {
      case CallEvent_CallStatus.CREATED:
        return call_status.CallStatus.CREATED;
      case CallEvent_CallStatus.BUSY:
        return call_status.CallStatus.BUSY;
      case CallEvent_CallStatus.DECLINED:
        return call_status.CallStatus.DECLINED;
      case CallEvent_CallStatus.ENDED:
        return call_status.CallStatus.ENDED;
      case CallEvent_CallStatus.INVITE:
        return call_status.CallStatus.INVITE;
      case CallEvent_CallStatus.IS_RINGING:
        return call_status.CallStatus.IS_RINGING;
      case CallEvent_CallStatus.JOINED:
        return call_status.CallStatus.JOINED;
      case CallEvent_CallStatus.KICK:
        return call_status.CallStatus.KICK;
      case CallEvent_CallStatus.LEFT:
        return call_status.CallStatus.LEFT;
    }
    return call_status.CallStatus.ENDED;
  }

  CallType findCallEventType(CallEvent_CallType eventCallType) {
    switch (eventCallType) {
      case CallEvent_CallType.VIDEO:
        return CallType.VIDEO;
      case CallEvent_CallType.AUDIO:
        return CallType.AUDIO;
      case CallEvent_CallType.GROUP_AUDIO:
        return CallType.GROUP_AUDIO;
      case CallEvent_CallType.GROUP_VIDEO:
        return CallType.GROUP_VIDEO;
    }
    return CallType.AUDIO;
  }

  CallEvent_CallStatus findCallEventStatusDB(CallStatus eventCallStatus) {
    switch (eventCallStatus) {
      case CallStatus.CREATED:
        return CallEvent_CallStatus.CREATED;
      case CallStatus.BUSY:
        return CallEvent_CallStatus.BUSY;
      case CallStatus.DECLINED:
        return CallEvent_CallStatus.DECLINED;
      case CallStatus.ENDED:
        return CallEvent_CallStatus.ENDED;
      case CallStatus.INVITE:
        return CallEvent_CallStatus.INVITE;
      case CallStatus.IS_RINGING:
        return CallEvent_CallStatus.IS_RINGING;
      case CallStatus.JOINED:
        return CallEvent_CallStatus.JOINED;
      case CallStatus.KICK:
        return CallEvent_CallStatus.KICK;
      case CallStatus.LEFT:
        return CallEvent_CallStatus.LEFT;
    }

  }

}
