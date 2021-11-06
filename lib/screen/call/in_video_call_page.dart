import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_bottom_row.dart';

class InVideoCallPage extends StatefulWidget {
  RTCVideoRenderer localRenderer;

  RTCVideoRenderer remoteRenderer;

  InVideoCallPage({Key key, this.localRenderer, this.remoteRenderer})
      : super(key: key);

  @override
  _InVideoCallPageState createState() => _InVideoCallPageState();
}

class _InVideoCallPageState extends State<InVideoCallPage> {
  double width = 100.0, height = 150.0;
  Offset position;

  @override
  void initState() {
    super.initState();
    position = Offset(10, 30);
  }

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;

    return Stack(
      children: <Widget>[
        RTCVideoView(
          widget.remoteRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirror: true,
        ),
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            child: Container(
              width: width,
              height: height,
              child: RTCVideoView(
                widget.localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),
            feedback: Container(
              child: RTCVideoView(
                widget.localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
              width: width,
              height: height,
            ),
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              setState(() {
                if (offset.dx > x / 2 && offset.dy > y / 2) {
                  position = Offset(x - width - 10, y - height - 30);
                }
                if (offset.dx < x / 2 && offset.dy > y / 2) {
                  position = Offset(10, y - height - 30);
                }
                if (offset.dx > x / 2 && offset.dy < y / 2) {
                  position = Offset(x - width - 10, 30);
                }
                if (offset.dx < x / 2 && offset.dy < y / 2) {
                  position = Offset(10, 30);
                }
              });
            },
          ),
        ),
        CallBottomRow(
          remoteRenderer: widget.remoteRenderer,
          localRenderer: widget.localRenderer,
        ),
      ],
    );
  }
}
