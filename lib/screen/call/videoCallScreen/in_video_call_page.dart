import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

import '../call_bottom_row.dart';

class InVideoCallPage extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final Function hangUp;
  final Uid roomUid;

  const InVideoCallPage(
      {Key? key,
      required this.localRenderer,
      required this.remoteRenderer,
      required this.roomUid,
      required this.hangUp})
      : super(key: key);

  @override
  _InVideoCallPageState createState() => _InVideoCallPageState();
}

class _InVideoCallPageState extends State<InVideoCallPage> {
  final callRepo = GetIt.I.get<CallRepo>();
  final double width = 100.0, height = 150.0;
  Offset position = const Offset(10, 30);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var x = MediaQuery.of(context).size.width;
    var y = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        StreamBuilder<bool>(
            stream: callRepo.mute_camera.stream,
            builder: (c, s) {
              if (s.hasData && s.data!) {
                return Stack(
                  children: [
                    RTCVideoView(
                      widget.remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                    Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: Draggable(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: RTCVideoView(
                            widget.localRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                            mirror: true,
                          ),
                        ),
                        feedback: SizedBox(
                          child: RTCVideoView(
                            widget.localRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                            mirror: true,
                          ),
                          width: width,
                          height: height,
                        ),
                        onDraggableCanceled:
                            (Velocity velocity, Offset offset) {
                          setState(() {
                            if (offset.dx > x / 2 && offset.dy > y / 2) {
                              position =
                                  Offset(x - width - 10, y - height - 30);
                            }
                            if (offset.dx < x / 2 && offset.dy > y / 2) {
                              position = Offset(10, y - height - 30);
                            }
                            if (offset.dx > x / 2 && offset.dy < y / 2) {
                              position = Offset(x - width - 10, 30);
                            }
                            if (offset.dx < x / 2 && offset.dy < y / 2) {
                              position = const Offset(10, 30);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return CenterAvatarInCall(
                  roomUid: widget.roomUid,
                );
              }
            }),
        CallBottomRow(
          hangUp: widget.hangUp,
        ),
      ],
    );
  }
}
