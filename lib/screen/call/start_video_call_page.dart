import 'package:deliver/box/room.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'call_bottom_row.dart';
import 'center_avatar_image-in-call.dart';

class StartVideoCallPage extends StatefulWidget {
  final Room room;
  RTCVideoRenderer localRenderer;

  String text;
  RTCVideoRenderer remoteRenderer;

  StartVideoCallPage(
      {Key key, this.text, this.room, this.localRenderer, this.remoteRenderer})
      : super(key: key);

  @override
  _StartVideoCallPageState createState() => _StartVideoCallPageState();
}

class _StartVideoCallPageState extends State<StartVideoCallPage> {
  final _logger = GetIt.I.get<Logger>();
  final _audioService = GetIt.I.get<AudioService>();

  @override
  void dispose() async {
    super.dispose();
    _logger.i("call dispose in start call status=${widget.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      RTCVideoView(
        widget.localRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: true,
      ),
      CenterAvatorInCall(
        room: widget.room,
      ),
      CallBottomRow(
        remoteRenderer: widget.localRenderer,
        localRenderer: widget.remoteRenderer,
      ),
      Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.45),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      )
    ]));
  }
}
