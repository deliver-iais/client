import 'dart:async';
import 'dart:core';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/start_video_call_page.dart';
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

import 'videoCallScreen/in_video_call_page.dart';

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

class CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  late final RTCVideoRenderer _localRenderer;

  late final RTCVideoRenderer _remoteRenderer;
  final callRepo = GetIt.I.get<CallRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  late final String random;
  BuildContext? dialogContext;

  final List<StreamSubscription<AccelerometerEvent>?> _accelerometerEvents =
      <StreamSubscription<AccelerometerEvent>>[];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }
      checkForSystemAlertWindowPermission();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    random = randomAlphaNumeric(10);
    callRepo.initRenderer();
    _localRenderer = callRepo.getLocalRenderer;
    _remoteRenderer = callRepo.getRemoteRenderer;
    if (!widget.isCallInitialized) {
      startCall();
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
        dialogContext = context;
        return AlertDialog(
          title: const Tgs.asset(
            'assets/animations/call_permission.tgs',
            width: 150,
            height: 150,
          ),
          content: Column(
            children: [
              Text(
                _i18n.get(
                  "alert_window_permission",
                ),
                textDirection: TextDirection.rtl,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: Text(
                _i18n.get(
                  "cancel",
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                _i18n.get("go_to_setting"),
              ),
              onPressed: () async {
                await Permission.systemAlertWindow.request();
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
    WidgetsBinding.instance.removeObserver(this);
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
    callRepo
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
        await callRepo.acceptCall(widget.roomUid);
      }
    } else if (widget.isVideoCall) {
      await callRepo.startCall(widget.roomUid, isVideo: true);
    } else {
      await callRepo.startCall(widget.roomUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: callRepo.callingStatus,
      builder: (context, snapshot) {
        _logger.i("callStatus-$random: ${snapshot.data}");
        switch (snapshot.data) {
          case CallStatus.CONNECTED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? StreamBuilder<bool>(
                    stream: callRepo.switching,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data == false) {
                          return InVideoCallPage(
                            localRenderer: _localRenderer,
                            remoteRenderer: _remoteRenderer,
                            roomUid: widget.roomUid,
                            hangUp: _hangUp,
                          );
                        } else {
                          return InVideoCallPage(
                            localRenderer: _remoteRenderer,
                            remoteRenderer: _localRenderer,
                            roomUid: widget.roomUid,
                            hangUp: _hangUp,
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.DISCONNECTED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? InVideoCallPage(
                    localRenderer: _localRenderer,
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_dis_connected"),
                    hangUp: _hangUp,
                  );
          case CallStatus.CONNECTING:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? InVideoCallPage(
                    localRenderer: _localRenderer,
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_connecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.RECONNECTING:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? InVideoCallPage(
                    localRenderer: _localRenderer,
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_reconnecting"),
                    hangUp: _hangUp,
                  );
          case CallStatus.FAILED:
            _audioService.stopBeepSound();
            return widget.isVideoCall
                ? InVideoCallPage(
                    localRenderer: _localRenderer,
                    remoteRenderer: _remoteRenderer,
                    roomUid: widget.roomUid,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_connection_failed"),
                    hangUp: _hangUp,
                  );
          case CallStatus.IS_RINGING:
          _audioService.playBeepSound();
          return widget.isVideoCall
              ? StartVideoCallPage(
            roomUid: widget.roomUid,
            localRenderer: _localRenderer,
            text: _i18n.get("call_ringing"),
            remoteRenderer: _remoteRenderer,
            isIncomingCall: widget.isIncomingCall,
            hangUp: _hangUp,
          )
              : AudioCallScreen(
            roomUid: widget.roomUid,
            callStatus: _i18n.get("call_ringing"),
            isIncomingCall: widget.isIncomingCall,
            hangUp: _hangUp,
          );
          case CallStatus.NO_ANSWER:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: _i18n.get("call_user_not_answer"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_user_not_answer"),
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  );
          case CallStatus.CREATED:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: _i18n.get("call_calling"),
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: !callRepo.isCaller,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: widget.isIncomingCall ? _i18n.get("call_incoming") : _i18n.get("call_calling"),
                    isIncomingCall: !callRepo.isCaller,
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
            callRepo.disposeRenderer();
            return AudioCallScreen(
              roomUid: widget.roomUid,
              callStatus: _i18n.get("call_ended"),
              isIncomingCall: widget.isIncomingCall,
              hangUp: _hangUp,
            );
          // case CallStatus.NO_CALL:
          //   return const Scaffold();
          case CallStatus.BUSY:
            _audioService.stopBeepSound();
            _audioService.playBusySound();
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "${_i18n.get("call_busy")}....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "${_i18n.get("call_busy")}....",
                    hangUp: _hangUp,
                  );
          case CallStatus.DECLINED:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "${_i18n.get("call_declined")}....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "${_i18n.get("call_declined")}....",
                    hangUp: _hangUp,
                  );
          case CallStatus.ACCEPTED:
            unawaited(callRepo.cancelCallNotification());
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: _i18n.get("call_accepted"),
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: _i18n.get("call_accepted"),
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
    callRepo.endCall();
  }
}
