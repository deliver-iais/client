import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'call_bottom_row.dart';
import 'center_avatar_image-in-call.dart';

class StartVideoCallPage extends StatefulWidget {
  final Uid roomUid;
  final RTCVideoRenderer localRenderer;
  final String text;
  final RTCVideoRenderer remoteRenderer;

  const StartVideoCallPage(
      {Key? key,
      required this.text,
      required this.roomUid,
      required this.localRenderer,
      required this.remoteRenderer})
      : super(key: key);

  @override
  _StartVideoCallPageState createState() => _StartVideoCallPageState();
}

class _StartVideoCallPageState extends State<StartVideoCallPage> {
  final _logger = GetIt.I.get<Logger>();

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
      CenterAvatarInCall(
        roomUid: widget.roomUid,
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
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ),
      )
    ]));
  }
}
