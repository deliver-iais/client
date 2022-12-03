import 'dart:async';
import 'dart:core';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:random_string/random_string.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:window_size/window_size.dart';

class CallScreen extends StatefulWidget {
  final Uid roomUid;
  final bool isCallAccepted;
  final bool isCallInitialized;
  final bool isIncomingCall;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.roomUid,
    this.isCallAccepted = false,
    this.isCallInitialized = false,
    this.isIncomingCall = false,
    this.isVideoCall = false,
  });

  @override
  CallScreenState createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  late final RTCVideoRenderer _localRenderer;
  late final RTCVideoRenderer _remoteRenderer;

  final _callRepo = GetIt.I.get<CallRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _callService = GetIt.I.get<CallService>();
  late final String random;
  Timer? endCallTimer;
  bool _isNear = false;

  final List<StreamSubscription<AccelerometerEvent>?> _accelerometerEvents =
      <StreamSubscription<AccelerometerEvent>>[];
  late StreamSubscription<dynamic> _streamSubscription;

  static const MethodChannel _channel = MethodChannel('screen_management');

  @override
  void initState() {
    if (isWindows) {
      setWindowMinSize(
        const Size(2 * FLUID_MAX_WIDTH, 1.5 * FLUID_MAX_HEIGHT),
      );
    }
    random = randomAlphaNumeric(10);
    _callService.initRenderer().then((value) {
      _localRenderer = _callService.getLocalRenderer;
      _remoteRenderer = _callService.getRemoteRenderer;
      if (!widget.isCallInitialized) {
        startCall();
        checkForSystemAlertWindowPermission();
      }
    });
    if (isAndroid) {
      _listenSensor();
    }
    super.initState();
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Tgs.asset(
            'assets/animations/call_permission.tgs',
            width: 150,
            height: 150,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _i18n.get(
                  "alert_window_permission",
                ),
                textDirection: _i18n.defaultTextDirection,
                style: theme.textTheme.bodyText1!
                    .copyWith(color: theme.primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection: _i18n.defaultTextDirection,
                  style: theme.textTheme.bodyText1!
                      .copyWith(color: theme.errorColor),
                ),
              )
            ],
          ),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).errorColor,
              ),
              child: Text(
                _i18n.get(
                  "cancel",
                ),
              ),
            ),
            TextButton(
              child: Text(
                _i18n.get("go_to_setting"),
              ),
              onPressed: () async {
                if (await Permission.systemAlertWindow.request().isGranted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkForSystemAlertWindowPermission() async {
    if (isAndroid &&
        await getDeviceVersion() >= 31 &&
        !await Permission.systemAlertWindow.status.isGranted) {
      showPermissionDialog();
    }
  }

  @override
  void dispose() {
    super.dispose();
    endCallTimer?.cancel();
    if (isWindows) {
      setWindowMinSize(
        const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100),
      );
    }
    if (isAndroid) {
      // for (final subscription in _accelerometerEvents) {
      //   subscription?.cancel();
      // }
      _streamSubscription.cancel();
      setOnLockScreenVisibility();
    }
  }

  Future<void> setOnLockScreenVisibility() async {
    await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
      isVisible: false,
    );
  }

  Future<void> _listenSensor() async {
    _accelerometerEvents.add(
      accelerometerEvents.listen((event) {
        if (event.z < 5 && event.y > 1 && _isNear) {
          _channel.invokeMethod("turnOff");
        } else {
          _channel.invokeMethod("turnOn");
        }
      }),
    );
    _streamSubscription = ProximitySensor.events.listen(
      (event) => setState(() => _isNear = (event > 0)),
    );
  }

  Future<void> startCall() async {
    _callRepo
      ..onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      })
      ..onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      })
      ..onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });

    //True means its VideoCall and false means AudioCall

    if (widget.isCallAccepted || widget.isIncomingCall) {
      if (widget.isCallAccepted) {
        await _callRepo.acceptCall(widget.roomUid);
      }
    } else if (widget.isVideoCall) {
      await _callRepo.startCall(widget.roomUid, isVideo: true);
    } else {
      await _callRepo.startCall(widget.roomUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CallStatus>(
      initialData: CallStatus.NO_CALL,
      stream: _callRepo.callingStatus,
      builder: (context, snapshot) {
        _logger.i("callStatus-$random: ${snapshot.data}");
        switch (snapshot.data) {
          case CallStatus.CONNECTED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connected"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.DISCONNECTED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_dis_connected"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_dis_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.CONNECTING:
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connecting"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.RECONNECTING:
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_reconnecting"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_reconnecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.FAILED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connection_failed"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_connection_failed"),
                    hangUp: _hangUp,
                  );
          case CallStatus.IS_RINGING:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_ringing"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_ringing"),
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  );
          case CallStatus.NO_ANSWER:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatusOnScreen: _i18n.get("call_user_not_answer"),
                    callStatus: snapshot.data!,
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_user_not_answer"),
                    hangUp: _hangUp,
                  );
          case CallStatus.CREATED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: widget.isIncomingCall
                        ? _i18n.get("call_incoming")
                        : _i18n.get("call_calling"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: !_callRepo.isCaller,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: widget.isIncomingCall
                        ? _i18n.get("call_incoming")
                        : _i18n.get("call_calling"),
                    isIncomingCall: !_callRepo.isCaller,
                    hangUp: _hangUp,
                  );
          case CallStatus.ENDED:
            _logger.i("END!");
            _audioService.playEndCallSound();
            endCallTimer = Timer(const Duration(milliseconds: 1500), () async {
              if (_routingService.canPop()) {
                _routingService.pop();
              }
            });
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_ended"),
                    remoteRenderer: _remoteRenderer,
                    // isIncomingCall:
                    //     widget.isIncomingCall && !_callRepo.isConnected,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_ended"),
                    // isIncomingCall:
                    //     widget.isIncomingCall && !_callRepo.isConnected,
                    hangUp: _hangUp,
                  );
          case CallStatus.BUSY:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: "${_i18n.get("call_busy")}....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: "${_i18n.get("call_busy")}....",
                    hangUp: _hangUp,
                  );
          case CallStatus.DECLINED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: "${_i18n.get("call_declined")}....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: "${_i18n.get("call_declined")}....",
                    hangUp: _hangUp,
                  );
          case CallStatus.ACCEPTED:
            unawaited(_callRepo.cancelCallNotification());
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_accepted"),
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: snapshot.data!,
                    callStatusOnScreen: _i18n.get("call_accepted"),
                    hangUp: _hangUp,
                  );
          case CallStatus.NO_CALL:
            return const Scaffold();
          case null:
            return const Scaffold();
        }
      },
    );
  }

  void _hangUp() {
    _logger.i("Call hang Up ...!");
    _audioService.stopCallAudioPlayer();
    if(!_callService.isHangedUp) {
      _callRepo.endCall();
      _callService.setCallHangedUp = true;
    }
  }
}
