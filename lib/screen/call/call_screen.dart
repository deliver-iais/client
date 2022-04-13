import 'dart:async';
import 'dart:core';

import 'package:all_sensors2/all_sensors2.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/start_video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'videoCallScreen/in_video_call_page.dart';

class CallScreen extends StatefulWidget {
  final Uid roomUid;
  final bool isCallAccepted;
  final bool isCallInitialized;
  final bool isIncomingCall;
  final bool isVideoCall;
  final Widget lastWidget;

  const CallScreen({
    Key? key,
    required this.roomUid,
    this.isCallAccepted = false,
    this.isCallInitialized = false,
    this.isIncomingCall = false,
    this.isVideoCall = false,
    required this.lastWidget,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final RTCVideoRenderer _localRenderer;

  late final RTCVideoRenderer _remoteRenderer;
  final callRepo = GetIt.I.get<CallRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
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

  @override
  void dispose() {
    super.dispose();
    if (isAndroid) {
      for (final subscription in _streamSubscriptions) {
        subscription.cancel();
      }
    }
  }

  Future<void> _listenSensor() async {
    _streamSubscriptions.add(proximityEvents!.listen((event) {}));
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
      await callRepo.initCall(isOffer: true);
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
        _logger.i("callStatus: " + snapshot.data.toString());
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
                    callStatus: "Connected",
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
                    callStatus: "disConnected",
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
                    callStatus: "Connecting",
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
                    callStatus: "Reconnecting",
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
                    callStatus: "Connection failed",
                    hangUp: _hangUp,
                  );
          case CallStatus.IS_RINGING:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Ringing",
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Ringing",
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  );
          case CallStatus.NO_ANSWER:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "User not answer",
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "User not answer",
                    isIncomingCall: widget.isIncomingCall,
                    hangUp: _hangUp,
                  );
          case CallStatus.CREATED:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Calling",
                    remoteRenderer: _remoteRenderer,
                    isIncomingCall: !callRepo.isCaller,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Calling",
                    isIncomingCall: !callRepo.isCaller,
                    hangUp: _hangUp,
                  );
          case CallStatus.ENDED:
            _logger.i("END!");
            _audioService.playEndCallSound();

            Timer(const Duration(milliseconds: 1500), () async {
              if (_routingService.canPop() && !isDesktop) {
                _routingService.pop();
              }
            });
            callRepo.disposeRenderer();
            return AudioCallScreen(
              roomUid: widget.roomUid,
              callStatus: "Ended",
              isIncomingCall: widget.isIncomingCall,
              hangUp: _hangUp,
            );
          case CallStatus.NO_CALL:
            return widget.lastWidget;
          case CallStatus.BUSY:
            _audioService.stopBeepSound();
            _audioService.playBusySound();
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Busy....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Busy....",
                    hangUp: _hangUp,
                  );
          case CallStatus.DECLINED:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Declined....",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Declined....",
                    hangUp: _hangUp,
                  );
          case CallStatus.ACCEPTED:
            return widget.isVideoCall
                ? StartVideoCallPage(
                    roomUid: widget.roomUid,
                    localRenderer: _localRenderer,
                    text: "Accepted",
                    remoteRenderer: _remoteRenderer,
                    hangUp: _hangUp,
                  )
                : AudioCallScreen(
                    roomUid: widget.roomUid,
                    callStatus: "Accepted",
                    hangUp: _hangUp,
                  );

          default:
            {
              return widget.lastWidget;
            }
        }
      },
    );
  }

  Future<void> _hangUp() async {
    _logger.i("Call hang Up ...!");
    _audioService.stopBeepSound();
    callRepo.endCall();
  }
}
