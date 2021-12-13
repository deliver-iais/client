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
  final bool isInitial;
  final bool isIncomingCall;

  const CallScreen(
      {Key? key,
      required this.roomUid,
      required this.isAccepted,
      required this.isInitial,
      this.isIncomingCall = false})
      : super(key: key);

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

  @override
  void initState() {
    modifyRoutingByNotificationAudioCall.add({"": false});
    callRepo.initRenderer();
    _localRenderer = callRepo.getLocalRenderer;
    _remoteRenderer = callRepo.getRemoteRenderer;
    if (!widget.isInitial) {
      startCall();
    }
    super.initState();
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

    if (widget.isAccepted || widget.isIncomingCall) {
      await callRepo.initCall(true);
      if (widget.isAccepted) {
        callRepo.acceptCall(widget.roomUid);
      }
    } else if (callRepo.isVideo) {
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
          _logger.i("callStatus: " + snapshot.data.toString());
          switch (snapshot.data) {
            case CallStatus.CONNECTED:
              _audioService.stopPlayBeepSound();
              return callRepo.isVideo
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
            case CallStatus.DISCONNECTED:
              _audioService.stopPlayBeepSound();
              return callRepo.isVideo
                  ? InVideoCallPage(
                      localRenderer: _localRenderer,
                      remoteRenderer: _remoteRenderer,
                      roomUid: widget.roomUid,
                      hangUp: _hangUp,
                    )
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "disConnected",
                      hangUp: _hangUp);
            case CallStatus.FAILED:
              _audioService.stopPlayBeepSound();
              return callRepo.isVideo
                  ? InVideoCallPage(
                      localRenderer: _localRenderer,
                      remoteRenderer: _remoteRenderer,
                      roomUid: widget.roomUid,
                      hangUp: _hangUp,
                    )
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Connection failed",
                      hangUp: _hangUp);
            case CallStatus.IN_CALL:
              _audioService.stopPlayBeepSound();
              return callRepo.isVideo
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
            case CallStatus.IS_RINGING:
              _audioService.playBeepSound();
              return callRepo.isVideo
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Ringing...",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Ringing...",
                      isIncomingCall: widget.isIncomingCall,
                      hangUp: _hangUp,
                    );
            case CallStatus.CREATED:
              return callRepo.isVideo
                  ? StartVideoCallPage(
                      roomUid: widget.roomUid,
                      localRenderer: _localRenderer,
                      text: "Calling....",
                      remoteRenderer: _remoteRenderer,
                      hangUp: _hangUp)
                  : AudioCallScreen(
                      roomUid: widget.roomUid,
                      callStatus: "Calling....",
                      isIncomingCall: widget.isIncomingCall,
                      hangUp: _hangUp);
            case CallStatus.ENDED:
              _logger.i("END!");
              _audioService.stopPlayBeepSound();
              isDesktop()
                  ? _routingService.pop()
                  : Timer.run(() {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    });
              callRepo.disposeRenderer();
              return const SizedBox.shrink();
            case CallStatus.NO_CALL:
              return Container(
                color: Colors.green,
              );
            case CallStatus.BUSY:
              _audioService.stopPlayBeepSound();
              _audioService.playBusySound();
              return callRepo.isVideo
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
            case CallStatus.DECLINED:
              return callRepo.isVideo
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
            case CallStatus.ACCEPTED:
              return callRepo.isVideo
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
          }
        });
  }

  _hangUp() async {
    _logger.i("Call hang Up ...!");
    _audioService.stopPlayBeepSound();
    // if (isDesktop()) {
    //   _routingService.pop();
    // } else {
    //   Navigator.of(context).pop();
    // }
    callRepo.endCall();
  }
}
