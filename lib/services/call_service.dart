import 'dart:isolate';

import 'package:deliver/box/call_status.dart' as call_status;
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/current_call_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

enum UserCallState {
  /// User in Group Call then he Can't join any User or Start Own Call
  // ignore: constant_identifier_names
  IN_GROUP_CALL,

  /// User in User Call then he Can't join any Group or Start Own Call
  IN_USER_CALL,

  /// User Out of Call then he Can join any Group or User Call or Start Own Call
  // ignore: constant_identifier_names
  NOCALL,
}

class CallService {
  final _currentCall = GetIt.I.get<CurrentCallInfoDao>();
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _logger = GetIt.I.get<Logger>();

  final BehaviorSubject<CallEvents> callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  final BehaviorSubject<CallEvents> _callEvents =
      BehaviorSubject.seeded(CallEvents.none);

  bool shouldRemoveData = false;

  CallService() {
    _callEvents.distinct().listen((event) {
      callEvents.add(event);
      _featureFlags.enableVoiceCallFeatureFlag();
    });
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

  UserCallState _callState = UserCallState.NOCALL;

  String _callId = "";

  Uid _roomUid = Uid.getDefault();

  ReceivePort? _receivePort;

  SendPort? _sendPort;

  ReceivePort? get getReceivePort => _receivePort;

  SendPort? get getSendPort => _sendPort;

  UserCallState get getUserCallState => _callState;

  Uid get getRoomUid => _roomUid;

  String get getCallId => _callId;

  set setUserCallState(UserCallState cs) => _callState = cs;

  set setSendPort(SendPort? sp) => _sendPort = sp;

  set setRoomUid(Uid ru) => _roomUid = ru;

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
      case CallEvent_CallStatus.IS_RINGING:
        return call_status.CallStatus.IS_RINGING;
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

  Future<void> clearCallData({bool forceToClearData = false}) async {
    if (shouldRemoveData || forceToClearData) {
      _logger.d("Clearing Call Data");
      _callId = "";
      _callState = UserCallState.NOCALL;
      await FlutterForegroundTask.clearAllData();
      await removeCallFromDb();
    }
  }

  Future<bool> foregroundTaskInitializing() async {
    if (isAndroid) {
      await _initForegroundTask();
      if (await _startForegroundTask()) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        playSound: true,
        isSticky: false,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'endCall', text: 'End Call'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    ReceivePort? receivePort;
    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: '$APPLICATION_NAME Call on BackGround',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      return true;
    }
    return false;
  }

  Future<bool> stopForegroundTask() async =>
      FlutterForegroundTask.stopService();
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  // ignore: prefer_typing_uninitialized_variables
  late final SendPort? sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    sPort = sendPort;
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    if (id == "endCall") {
      sPort?.send("endCall");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/call-screen");
    sPort?.send('onNotificationPressed');
  }
}
