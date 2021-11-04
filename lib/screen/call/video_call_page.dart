import 'package:deliver/box/room.dart';
import 'package:deliver/screen/call/start_video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/video_call_service.dart';
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
  final _videoCallService = GetIt.I.get<VideoCallService>();
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
    _videoCallService?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _videoCallService?.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    _videoCallService?.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });

    await _videoCallService.startCall(widget.room.uid.asUid());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _videoCallService.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            if (snapshot.data == "answer") {
              _logger.i("we got an answer an go to in call page");
              return InVideoCallPage(
                  localRenderer: _localRenderer,remoteRenderer:_remoteRenderer);
            } else if (snapshot.data == "end") {
              _logger.i("we got an end call back to rooms");
              _videoCallService.endCall();
              _remoteRenderer.dispose();
              _localRenderer.dispose();
              _routingService.pop();
              return SizedBox.shrink();
            } else {
              _logger.i("we got busy / reject / ringing");
              return StartVideoCallPage(
                room: widget.room,
                localRenderer: _localRenderer,
                text: snapshot.data,
                remoteRenderer: _remoteRenderer,
              );
            }
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
