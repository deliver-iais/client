import 'dart:async';
import 'dart:core';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  late final String random;

  final List<StreamSubscription<AccelerometerEvent>?> _accelerometerEvents =
      <StreamSubscription<AccelerometerEvent>>[];

  @override
  void initState() {
    random = randomAlphaNumeric(10);
    _callRepo.initRenderer();
    _localRenderer = _callRepo.getLocalRenderer;
    _remoteRenderer = _callRepo.getRemoteRenderer;
    if (!widget.isCallInitialized) {
      startCall();
      checkForSystemAlertWindowPermission();
    }
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
                textDirection:
                    _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                style: theme.textTheme.bodyText1!
                    .copyWith(color: theme.primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection:
                      _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
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
                primary: Theme.of(context).errorColor,
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
    if (isAndroid) {
      for (final subscription in _accelerometerEvents) {
        subscription?.cancel();
      }
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
        if (event.z < 5 && event.y > 1) {
          //_logger.i('Proximity sensor detected');
        } else {
          //_logger.i('Proximity sensor not detected');
        }
      }),
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
    return StreamBuilder(
      stream: _callRepo.callingStatus,
      builder: (context, snapshot) {
        _logger.i("callStatus-$random: ${snapshot.data}");
        switch (snapshot.data) {
          case CallStatus.CONNECTED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    text: "Connected",
                    callStatusOnScreen: _i18n.get("call_connected"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Connected",
                    callStatusOnScreen: _i18n.get("call_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.DISCONNECTED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    text: "disConnected",
                    callStatusOnScreen: _i18n.get("call_dis_connected"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "disConnected",
                    callStatusOnScreen: _i18n.get("call_dis_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.CONNECTING:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    text: "Connecting",
                    callStatusOnScreen: _i18n.get("call_connecting"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Connecting",
                    callStatusOnScreen: _i18n.get("call_connecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.RECONNECTING:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    text: "Reconnecting",
                    callStatusOnScreen: _i18n.get("call_reconnecting"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Reconnecting",
                    callStatusOnScreen: _i18n.get("call_reconnecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.FAILED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    localRenderer: _localRenderer,
                    text: "Connection failed",
                    callStatusOnScreen: _i18n.get("call_connection_failed"),
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Connection failed",
                    callStatusOnScreen: _i18n.get("call_connection_failed"),
                    hangUp: _hangUp,
                  );
          case CallStatus.IS_RINGING:
            _audioService.playBeepSound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Ringing",
                    callStatusOnScreen: _i18n.get("call_ringing"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Ringing",
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
                    text: "User not answer",
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "User not answer",
                    callStatusOnScreen: _i18n.get("call_user_not_answer"),
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  );
          case CallStatus.CREATED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Calling",
                    callStatusOnScreen: widget.isIncomingCall
                        ? _i18n.get("call_incoming")
                        : _i18n.get("call_calling"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: !_callRepo.isCaller,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Calling",
                    callStatusOnScreen: widget.isIncomingCall
                        ? _i18n.get("call_incoming")
                        : _i18n.get("call_calling"),
                    isIncomingCall: !_callRepo.isCaller,
                    hangUp: _hangUp,
                  );
          case CallStatus.ENDED:
            _logger.i("END!");
            _audioService.playEndCallSound();
            Timer(const Duration(milliseconds: 1500), () async {
              if (_routingService.canPop()) {
                _routingService.pop();
              }
            });
            _callRepo.disposeRenderer();
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Ended",
                    callStatusOnScreen: _i18n.get("call_ended"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall:
                        widget.isIncomingCall && !_callRepo.isConnected,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Ended",
                    callStatusOnScreen: _i18n.get("call_ended"),
                    isIncomingCall:
                        widget.isIncomingCall && !_callRepo.isConnected,
                    hangUp: _hangUp,
                  );
          // case CallStatus.NO_CALL:
          //   return const Scaffold();
          case CallStatus.BUSY:
            _audioService.stopBeepSound();
            _audioService.playBusySound();
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Busy....",
                    callStatusOnScreen: "${_i18n.get("call_busy")}....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Busy....",
                    callStatusOnScreen: "${_i18n.get("call_busy")}....",
                    hangUp: _hangUp,
                  );
          case CallStatus.DECLINED:
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Declined....",
                    callStatusOnScreen: "${_i18n.get("call_declined")}....",
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: true,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Declined....",
                    callStatusOnScreen: "${_i18n.get("call_declined")}....",
                    hangUp: _hangUp,
                    isIncomingCall: true,
                  );
          case CallStatus.ACCEPTED:
            unawaited(_callRepo.cancelCallNotification());
            return widget.isVideoCall
                ? VideoCallScreen(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Accepted",
                    callStatusOnScreen: _i18n.get("call_accepted"),
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Accepted",
                    callStatusOnScreen: _i18n.get("call_accepted"),
                    hangUp: _hangUp,
                  );

          default:
            {
              return const Scaffold();
            }
        }
      },
    );
  }

  void _hangUp() {
    _logger.i("Call hang Up ...!");
    _audioService.stopBeepSound();
    _callRepo.endCall();
  }
}
