import 'package:deliver/box/room.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/start_video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'in_video_call_page.dart';

class VideoCallPage extends StatefulWidget {
  final Room room;

  VideoCallPage({Key key, this.room}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _logger = GetIt.I.get<Logger>();

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  @override
  void initState() {
    _initRenderer();
    startCall();
    super.initState();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void startCall() async {
    callRepo?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    callRepo?.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    callRepo?.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });

    await callRepo.startCall(widget.room.uid.asUid());


  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            if (snapshot.data == CallStatus.ACCEPTED) {
              _logger.i("in call");
              _audioService.stopPlayBeepSound();
              return InVideoCallPage(
                  localRenderer: _localRenderer,
                  remoteRenderer: _remoteRenderer);
            } else if (snapshot.data == CallStatus.ENDED) {
              _logger.i("call ended status");
              _audioService.stopPlayBeepSound();
              _routingService.pop();
              _remoteRenderer.dispose();
              _localRenderer.dispose();
              return SizedBox.shrink();
            } else if (snapshot.data == CallStatus.BUSY ||
                snapshot.data == CallStatus.DECLINED ||
                snapshot.data == CallStatus.DECLINED ||
                snapshot.data == CallStatus.CREATED ||
                snapshot.data == CallStatus.IS_RINGING) {
              _logger.i("we got busy / reject / ringing /conecting");
              String text;
              switch (snapshot.data) {
                case CallStatus.IS_RINGING:
                  text = "is Ringing";
                  _audioService.playBeepSound();
                  break;
                case CallStatus.DECLINED:
                  text = "DECLINED";
                  _audioService.stopPlayBeepSound();
                  break;
                case CallStatus.BUSY:
                  text = "Busy";
                  _audioService.stopPlayBeepSound();
                  break;
                case CallStatus.CREATED:
                  text = "Conecting";
                  break;
              }
              return StartVideoCallPage(
                room: widget.room,
                localRenderer: _localRenderer,
                text: text,
                remoteRenderer: _remoteRenderer,
              );
            } else if (snapshot.data == CallStatus.NO_CALL) {
              return Container(
                color: Colors.green,
              );
            } else
              return SizedBox.shrink();
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
