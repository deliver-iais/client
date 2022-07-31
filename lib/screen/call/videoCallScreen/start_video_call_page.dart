import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../../../repository/callRepo.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../call_bottom_icons.dart';
import '../center_avatar_image-in-call.dart';

class StartVideoCallPage extends StatefulWidget {
  final Uid roomUid;
  final RTCVideoRenderer localRenderer;
  final String text;
  final RTCVideoRenderer remoteRenderer;
  final void Function() hangUp;
  final bool isIncomingCall;

  const StartVideoCallPage({
    super.key,
    required this.text,
    required this.roomUid,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  StartVideoCallPageState createState() => StartVideoCallPageState();
}

class StartVideoCallPageState extends State<StartVideoCallPage> {
  final _logger = GetIt.I.get<Logger>();
  final _callRepo = GetIt.I.get<CallRepo>();

  @override
  Future<void> dispose() async {
    super.dispose();
    _logger.i("call dispose in start call status=${widget.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          OrientationBuilder(
            builder: (context, orientation) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color.fromARGB(255, 75, 105, 100),
                      Color.fromARGB(255, 49, 89, 107),
                    ],
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: _callRepo.sharing,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!) {
                          return Container(
                            margin: const EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: RTCVideoView(
                              widget.localRenderer,
                            ),
                          );
                        } else {
                          return Container(
                            margin:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: RTCVideoView(
                              widget.localRenderer,
                              mirror: true,
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              );
            },
          ),
          CenterAvatarInCall(
            roomUid: widget.roomUid,
          ),
          CallBottomRow(
            hangUp: widget.hangUp,
            isIncomingCall: widget.isIncomingCall,
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
        ],
      ),
    );
  }
}
