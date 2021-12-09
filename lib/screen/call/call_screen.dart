import 'dart:async';
import 'dart:core';

import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_screen.dart';
import 'package:deliver/screen/call/videoCallScreen/start_video_call_page.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
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
  final bool isAccepted;
  final bool isVideoCall;
  final bool isInitial;

  const CallScreen(
      {Key? key,
      required this.roomUid,
      required this.isAccepted,
      required this.isVideoCall,
      required this.isInitial})
      : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final callRepo = GetIt.I.get<CallRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    modifyRoutingByNotificationAudioCall.add({"": false});
    initRenderer();
    if (!widget.isInitial) {
      startCall();
    }
    super.initState();
  }

  initRenderer() async {
    _logger.i("Initialize Renderers");
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  disposeRenderer() async {
    _logger.i("Dispose Renderers");
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }

  void startCall() async {
    callRepo.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    callRepo.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    callRepo.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });

    //True means its VideoCall and false means AudioCall

    if (widget.isAccepted) {
      await callRepo.initCall(true);
      callRepo.acceptCall(widget.roomUid);
    } else if (widget.isVideoCall) {
      await callRepo.startCall(widget.roomUid, true);
    } else {
      await callRepo.startCall(widget.roomUid, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          switch (snapshot.data) {
            case CallStatus.CONNECTED:
              _audioService.stopPlayBeepSound();
              return widget.isVideoCall
                  ? InVideoCallPage(
                localRenderer: _localRenderer,
                remoteRenderer: _remoteRenderer,
                roomUid: widget.roomUid,
                hangUp: _hangUp,
              )
                  : AudioCallScreen(
                  roomUid: widget.roomUid,
                  callStatus: "Connected",
                  hangUp: _hangUp);
            case CallStatus.IN_CALL:
              _audioService.stopPlayBeepSound();
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
                      hangUp: _hangUp);
              break;
            case CallStatus.IS_RINGING:
              _audioService.playBeepSound();
              return widget.isVideoCall
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Ringing...",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Ringing...",
                      hangUp: _hangUp,
                    );
              break;
            case CallStatus.CREATED:
              return widget.isVideoCall
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Calling....",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Calling....",
                      hangUp: _hangUp);
              break;
            case CallStatus.ENDED:
              disposeRenderer();
              _audioService.stopPlayBeepSound();
              isDesktop()
                  ? _routingService.pop()
                  : Timer.run(() {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    });
              return const SizedBox.shrink();
              break;
            case CallStatus.NO_CALL:
              return Container(
                color: Colors.green,
              );
              break;
            case CallStatus.BUSY:
              _audioService.stopPlayBeepSound();
              _audioService.playBusySound();
              return widget.isVideoCall
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Busy....",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Busy....",
                      hangUp: _hangUp);
              break;
            case CallStatus.DECLINED:
              return widget.isVideoCall
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Declined....",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Declined....",
                      hangUp: _hangUp);
              break;
            case CallStatus.ACCEPTED:
              return widget.isVideoCall
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Accepted",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Accepted",
                      hangUp: _hangUp);

            default:
              {
                return Container(
                  color: Colors.red,
                );
              }
              break;
          }
        });
  }

  _hangUp() async {
    _audioService.stopPlayBeepSound();
    if (isDesktop()) {
      _routingService.pop();
    } else {
      Navigator.of(context).pop();
    }
    await disposeRenderer();
    await callRepo.endCall();
  }
}
