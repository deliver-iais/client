import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/current_call_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/callRepo.dart' as call_status;
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserCallState {
  /// User in Group Call then he Can't join any User or Start Own Call
  IN_GROUP_CALL,

  /// User in User Call then he Can't join any Group or Start Own Call
  IN_USER_CALL,

  /// User Out of Call then he Can join any Group or User Call or Start Own Call
  NO_CALL,
}

class CallService {
  final _currentCall = GetIt.I.get<CurrentCallInfoDao>();
  final _logger = GetIt.I.get<Logger>();

  final BehaviorSubject<CallEvents> callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  late SharedPreferences _prefs;

  bool shouldRemoveData = false;

  final BehaviorSubject<bool> isCallStart = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isCallStart = BehaviorSubject.seeded(false);

  bool isInitRenderer = false;
  bool isHole = false;

  CallService() {
    SharedPreferences.getInstance().then((p) => _prefs = p);
    _callEvents.distinct().listen((event) {
      callEvents.add(event);
    });
    _isCallStart.distinct().listen((event) {
      isCallStart.add(event);
    });
  }

  void setCallStart({required bool callStart}) {
    _isCallStart.add(callStart);
  }

  void addCallEvent(CallEvents event) {
    _callEvents.add(event);
  }

  Future<void> saveCallOnDb(CurrentCallInfo callInfo) async {
    await _currentCall.save(callInfo);
  }

  Stream<CurrentCallInfo?> watchCurrentCall() {
    return _currentCall.watchCurrentCall();
  }

  Future<void> removeCallFromDb() async {
    await _currentCall.remove();
  }

  Future<CurrentCallInfo?> loadCurrentCall() async {
    return _currentCall.get();
  }

  Future<void> initRenderer() async {
    if (!isInitRenderer) {
      isInitRenderer = true;
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _logger.i("Initialize Renderers");
    }
  }

  Future<void> _disposeRenderer() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    _logger.i("Dispose Renderers");
  }

  UserCallState _callState = UserCallState.NO_CALL;

  String _callId = "";

  bool _isHangedUp = false;

  Uid _roomUid = Uid.getDefault();

  UserCallState get getUserCallState => _callState;

  Uid get getRoomUid => _roomUid;

  String get getCallId => _callId;

  bool get isHangedUp => _isHangedUp;

  RTCVideoRenderer get getLocalRenderer => _localRenderer;

  RTCVideoRenderer get getRemoteRenderer => _remoteRenderer;

  set setUserCallState(UserCallState cs) => _callState = cs;

  set setRoomUid(Uid ru) => _roomUid = ru;

  set setCallId(String callId) => _callId = callId;

  set setCallHangedUp(bool isHangedUp) => _isHangedUp = isHangedUp;

  CallStatus findCallEventStatusProto(
    CallEvent_CallStatus eventCallStatus,
  ) {
    switch (eventCallStatus) {
      case CallEvent_CallStatus.CREATED:
        return CallStatus.CREATED;
      case CallEvent_CallStatus.BUSY:
        return CallStatus.BUSY;
      case CallEvent_CallStatus.DECLINED:
        return CallStatus.DECLINED;
      case CallEvent_CallStatus.ENDED:
        return CallStatus.ENDED;
      case CallEvent_CallStatus.IS_RINGING:
        return CallStatus.IS_RINGING;
    }
    return CallStatus.ENDED;
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

  CallEvent_CallType findProtoCallEventType(CallType eventCallType) {
    switch (eventCallType) {
      case CallType.VIDEO:
        return CallEvent_CallType.VIDEO;
      case CallType.AUDIO:
        return CallEvent_CallType.AUDIO;
      case CallType.GROUP_AUDIO:
        return CallEvent_CallType.GROUP_AUDIO;
      case CallType.GROUP_VIDEO:
        return CallEvent_CallType.GROUP_VIDEO;
    }
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
      case CallStatus.IS_RINGING:
        return CallEvent_CallStatus.IS_RINGING;
    }
  }

  String writeCallEventsToJson(CallEvents event) {
    return (CallEvent()
          ..callId = event.callId
          ..callType = event.callEvent!.callType
          ..callDuration = event.callEvent!.callDuration
          ..callStatus = event.callEvent!.callStatus)
        .writeToJson();
  }

  Future<void> clearCallData({
    bool forceToClearData = false,
    bool isSaveCallData = false,
  }) async {
    if (isSaveCallData) {
      final callData = CallData(
        _callId,
        _roomUid.asString(),
        clock.now().millisecondsSinceEpoch + 10000,
      );
      saveLastCallStatusOnSharedPrefCallSlot(callData);
    }
    if (shouldRemoveData || forceToClearData) {
      _logger.i("Clearing Call Data");
      _callId = "";
      _callState = UserCallState.NO_CALL;
      isInitRenderer = false;
      _isHangedUp = false;
      isHole = false;
      _roomUid = Uid.getDefault();
      await removeCallFromDb();
    }
  }

  Future<void> disposeCallData({bool forceToClearData = false}) async {
    if (shouldRemoveData || forceToClearData) {
      await FlutterForegroundTask.clearAllData();
      await _disposeRenderer();
    }
  }

  bool isHiddenCallBottomRow(call_status.CallStatus callStatus) {
    return callStatus == call_status.CallStatus.CONNECTED;
  }

  bool checkIncomingCallIsRepeated(String callId, String roomUid) {
    if (!_isCallDataInSharedPref(
      callId,
      roomUid,
      SHARED_DAO_LAST_CALL_DATA_SLOT_1,
    )) {
      if (!_isCallDataInSharedPref(
        callId,
        roomUid,
        SHARED_DAO_LAST_CALL_DATA_SLOT_2,
      )) {
        if (!_isCallDataInSharedPref(
          callId,
          roomUid,
          SHARED_DAO_LAST_CALL_DATA_SLOT_3,
        )) {
          return false;
        }
      }
    }
    return true;
  }

  bool _isCallDataInSharedPref(String callId, String roomUid, String slot) {
    final callDataSlot = _prefs.getString(slot);
    if (callDataSlot != null) {
      final CallData callData = jsonDecode(callDataSlot);
      if (callData.callId == callId && callData.roomUid == roomUid) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  void saveLastCallStatusOnSharedPrefCallSlot(CallData data) {
    var replacedSlot = SHARED_DAO_LAST_CALL_DATA_SLOT_1;
    var minExpireTime =
        _checkSlotAndSaveIfPossible(data, SHARED_DAO_LAST_CALL_DATA_SLOT_1);
    if (minExpireTime != 0) {
      final tempExpireTime = _checkSlotAndSaveIfPossible(
        data,
        SHARED_DAO_LAST_CALL_DATA_SLOT_2,
      );
      if (minExpireTime > tempExpireTime) {
        replacedSlot = SHARED_DAO_LAST_CALL_DATA_SLOT_2;
        minExpireTime = tempExpireTime;
      }
    } else {
      return;
    }
    if (minExpireTime != 0) {
      final tempExpireTime = _checkSlotAndSaveIfPossible(
        data,
        SHARED_DAO_LAST_CALL_DATA_SLOT_3,
      );
      if (minExpireTime > tempExpireTime) {
        replacedSlot = SHARED_DAO_LAST_CALL_DATA_SLOT_3;
        minExpireTime = tempExpireTime;
      }
    } else {
      return;
    }
    if (minExpireTime != 0) {
      _prefs.setString(replacedSlot, jsonEncode(data));
    } else {
      return;
    }
  }

  int _checkSlotAndSaveIfPossible(CallData data, String slot) {
    final callDataSlot = _prefs.getString(slot);
    if (callDataSlot != null) {
      final CallData callData = jsonDecode(callDataSlot);
      if (((callData.expireTime - clock.now().millisecondsSinceEpoch).abs()) >
          100000) {
        // 100 sec ExpireTime
        _prefs.setString(slot, jsonEncode(data));
        return data.expireTime;
      } else {
        return 0;
      }
    } else {
      _prefs.setString(slot, jsonEncode(data));
      return data.expireTime;
    }
  }
}

class CallData {
  final String callId;
  final String roomUid;
  final int expireTime;

  const CallData(this.callId, this.roomUid, this.expireTime);
}
