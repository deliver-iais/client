import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/call_data_usage.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/call_data_usage_dao.dart';
import 'package:deliver/box/last_call_status.dart';
import 'package:deliver/isar/dao/current_call_dao_isar.dart'
    if (dart.library.html) 'package:deliver/hive/dao/current_call_dao_hive.dart';
import 'package:deliver/isar/dao/last_call_status_dao_isar.dart'
    if (dart.library.html) 'package:deliver/hive/dao/last_call_status_dao_hive.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/callRepo.dart' as call_status;
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

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
  final _lastCallStatus = GetIt.I.get<LastCallStatusDao>();
  final _callDataUsage = GetIt.I.get<CallDataUsageDao>();
  final _logger = GetIt.I.get<Logger>();

  final _i18n = GetIt.I.get<I18N>();

  final BehaviorSubject<CallEvents> callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  bool shouldRemoveData = false;

  final BehaviorSubject<bool> isCallStart = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isCallStart = BehaviorSubject.seeded(false);

  bool isInitRenderer = false;
  bool isHole = false;

  CallService() {
    _isCallStart.distinct().listen((event) {
      isCallStart.add(event);
    });
  }

  void setCallStart({required bool callStart}) {
    _isCallStart.add(callStart);
  }

  void addCallEvent(CallEvents event) {
    callEvents.add(event);
  }

  Future<void> saveCallOnDb(CurrentCallInfo callInfo) async {
    await _currentCall.save(callInfo);
  }

  Future<void> saveIsSelectedOrAccepted({
    bool isAccepted = false,
    bool isSelectNotification = false,
  }) async {
    await _currentCall.saveAcceptOrSelectNotification(
      isAccepted: isAccepted,
      isSelectNotification: isSelectNotification,
    );
  }

  Future<void> saveCallOfferOnDb(
    String offerBody,
    String offerCandidate,
  ) async {
    await _currentCall.saveCallOffer(offerBody, offerCandidate);
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

  bool _isVideoCall = false;

  Uid _roomUid = Uid.getDefault();

  UserCallState get getUserCallState => _callState;

  Uid get getRoomUid => _roomUid;

  String get getCallId => _callId;

  bool get isHangedUp => _isHangedUp;

  bool get isVideoCall => _isVideoCall;

  RTCVideoRenderer get getLocalRenderer => _localRenderer;

  RTCVideoRenderer get getRemoteRenderer => _remoteRenderer;

  bool get hasCall => _callState != UserCallState.NO_CALL;

  set setUserCallState(UserCallState cs) => _callState = cs;

  set setRoomUid(Uid ru) => _roomUid = ru;

  set setCallId(String callId) => _callId = callId;

  set setVideoCall(bool isVideoCall) => _isVideoCall = isVideoCall;

  set setCallHangedUp(bool isHangedUp) => _isHangedUp = isHangedUp;

  CallStatus findCallEventStatusProto(
    CallEventV2 callEventV2,
  ) {
    switch (callEventV2.whichType()) {
      case CallEventV2_Type.answer:
        return CallStatus.ACCEPTED;
      case CallEventV2_Type.busy:
        return CallStatus.BUSY;
      case CallEventV2_Type.decline:
        return CallStatus.DECLINED;
      case CallEventV2_Type.end:
        return CallStatus.ENDED;
      case CallEventV2_Type.offer:
        return CallStatus.CREATED;
      case CallEventV2_Type.ringing:
        return CallStatus.IS_RINGING;
      case CallEventV2_Type.notSet:
        return CallStatus.ENDED;
    }
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

  CallEvents getCallEventsFromJson(String callEvent) {
    return CallEvents.callEvent(CallEventV2.fromJson(callEvent));
  }

  Future<void> clearCallData({
    bool forceToClearData = false,
    bool isSaveCallData = false,
  }) async {
    try {
      if (isSaveCallData) {
        await removeCallFromDb();
      }
    } catch (e) {
      _logger.e(e);
    } finally {
      if (shouldRemoveData || forceToClearData) {
        _logger.i("Clearing Call Data");
        _callId = "";
        _callState = UserCallState.NO_CALL;
        isInitRenderer = false;
        _isHangedUp = false;
        _isVideoCall = false;
        isHole = false;
        _roomUid = Uid.getDefault();
      }
    }
  }

  Future<void> saveCallStatusData() async {
    final callData = LastCallStatus(
      callId: _callId,
      roomUid: _roomUid.asString(),
      expireTime: clock.now().millisecondsSinceEpoch + 100000,
      id: -1,
    );
    await saveLastCallStatus(callData);
  }

  Future<void> disposeCallData({
    bool forceToClearData = false,
  }) async {
    if (shouldRemoveData || forceToClearData) {
      await FlutterForegroundTask.clearAllData();
      if (isInitRenderer) {
        await _disposeRenderer();
      }
    }
  }

  bool isHiddenCallBottomRow(call_status.CallStatus callStatus) {
    return callStatus == call_status.CallStatus.CONNECTED && _isVideoCall;
  }

  Future<bool?> checkIncomingCallIsRepeated(String callId, String roomUid) {
    return _lastCallStatus.isExist(callId, roomUid);
  }

  Future<void> saveLastCallStatus(LastCallStatus data) async {
    var replacedSlot = CallSlot.DATA_SLOT_1;
    var minExpireTime =
        await _checkSlotAndSaveIfPossible(data, CallSlot.DATA_SLOT_1);
    if (minExpireTime != 0) {
      final tempExpireTime = await _checkSlotAndSaveIfPossible(
        data,
        CallSlot.DATA_SLOT_2,
      );
      if (minExpireTime > tempExpireTime) {
        replacedSlot = CallSlot.DATA_SLOT_2;
        minExpireTime = tempExpireTime;
      }
    } else {
      return;
    }
    if (minExpireTime != 0) {
      final tempExpireTime = await _checkSlotAndSaveIfPossible(
        data,
        CallSlot.DATA_SLOT_3,
      );
      if (minExpireTime > tempExpireTime) {
        replacedSlot = CallSlot.DATA_SLOT_3;
        minExpireTime = tempExpireTime;
      }
    } else {
      return;
    }
    if (minExpireTime != 0) {
      data = data.copyWith(id: replacedSlot.index);
      await _lastCallStatus.save(data);
    } else {
      return;
    }
  }

  Future<void> saveCallDataUsage(int byteSend, int byteReceived) async {
    final callDataUsage = CallDataUsage(
      callId: _callId,
      byteSend: byteSend,
      byteReceived: byteReceived,
    );
    return _callDataUsage.save(callDataUsage);
  }

  Future<String> getCallDataUsage(String callId) async {
    final callDataUsage = await _callDataUsage.get(callId);
    final totalDataUsage =
        (callDataUsage?.byteSend ?? 0) + (callDataUsage?.byteReceived ?? 0);
    //calculate at KiloBytes
    if (totalDataUsage < 1000000) {
      // less than 1mB
      return "${(totalDataUsage / 1000).toStringAsFixed(2)} ${_i18n.get("kilo_byte")}";
    } else {
      return "${(totalDataUsage / 1000000).toStringAsFixed(2)} ${_i18n.get("mega_byte")}";
    }
  }

  Future<int> _checkSlotAndSaveIfPossible(
    LastCallStatus data,
    CallSlot callSlot,
  ) async {
    final callData = await _lastCallStatus.get(callSlot.index);
    if (callData == null) {
      data = data.copyWith(id: callSlot.index);
      await _lastCallStatus.save(data);
      return 0;
    }
    if (((callData.expireTime - clock.now().millisecondsSinceEpoch).abs()) >
        CALL_DATA_EXPIRE_CHECK_TIME_MS) {
      data = data.copyWith(id: callSlot.index);
      await _lastCallStatus.save(data);
      return 0;
    } else {
      return data.expireTime;
    }
  }

  VideoCallQualityDetails getVideoCallQualityDetails(
    VideoCallQuality videoCallQuality,
  ) {
    switch (videoCallQuality) {
      case VideoCallQuality.LOW:
        return VideoCallQualityDetails(
          width: 320,
          height: 240,
          frameRate: 20,
        );
      case VideoCallQuality.MEDIUM:
        return VideoCallQualityDetails(
          width: 480,
          height: 360,
          frameRate: 30,
        );
      case VideoCallQuality.HIGH:
        return VideoCallQualityDetails(
          width: 640,
          height: 480,
          frameRate: 30,
        );
      case VideoCallQuality.ULTRA:
        return VideoCallQualityDetails(
          width: 720,
          height: 540,
          frameRate: 30,
        );
    }
  }
}

class VideoCallQualityDetails {
  final int width;
  final int height;
  final int frameRate;

  VideoCallQualityDetails({
    required this.width,
    required this.height,
    required this.frameRate,
  });

  String getResolution() {
    return "$width x $height";
  }

  int getFrameRate() {
    if (settings.lowNetworkUsageVideoCall.value) {
      return 15;
    } else {
      return frameRate;
    }
  }
}
