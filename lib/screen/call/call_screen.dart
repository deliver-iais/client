import 'dart:async';
import 'dart:core';

import 'package:all_sensors/all_sensors.dart' as all_sensor;
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
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
    if (isDesktopNative) {
      setWindowMinSize(
        const Size(2 * FLUID_MAX_WIDTH, 1.5 * FLUID_MAX_HEIGHT),
      );
    }
    random = randomAlphaNumeric(10);
    _callService.initRenderer().then((value) {
      _localRenderer = _callService.getLocalRenderer;
      _remoteRenderer = _callService.getRemoteRenderer;

      if (!widget.isCallInitialized) {
        _startCall();
        checkForSystemAlertWindowPermission();
        if (isAndroidNative) {
          _listenSensor();
        }
      }
    });
    super.initState();
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Ws.asset(
            'assets/animations/call_permission.ws',
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
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.primary),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection: _i18n.defaultTextDirection,
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.error),
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
                foregroundColor: Theme.of(context).colorScheme.error,
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
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkForSystemAlertWindowPermission() async {
    if (isAndroidNative &&
        await getDeviceVersion() >= 31 &&
        !await Permission.systemAlertWindow.status.isGranted) {
      showPermissionDialog();
    }
  }

  @override
  void dispose() {
    super.dispose();
    endCallTimer?.cancel();
    if (isDesktopNative) {
      setWindowMinSize(
        const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100),
      );
    }
    if (isAndroidNative) {
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
    _streamSubscription = all_sensor.proximityEvents!.listen(
      (event) => setState(() => _isNear = event.getValue()),
    );
  }

  Future<void> _startCall() async {
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
    } else {
      await (_callRepo.startCall(widget.roomUid, isVideo: widget.isVideoCall));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVideoCall
        ? VideoCallScreen(
            roomUid: widget.roomUid,
            hangUp: _hangUp,
            isIncomingCall: widget.isIncomingCall,
          )
        : AudioCallScreen(
            roomUid: widget.roomUid,
            hangUp: _hangUp,
            isIncomingCall: widget.isIncomingCall,
          );
  }

  void _hangUp() {
    _logger.i("Call hang Up ...!");
    _audioService.stopCallAudioPlayer();
    if (!_callService.isHangedUp) {
      _callRepo.endCall();
      _callService.setCallHangedUp = true;
    }
  }
}
