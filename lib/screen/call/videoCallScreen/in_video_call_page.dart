import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class InVideoCallPage extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final void Function() hangUp;
  final Uid roomUid;

  const InVideoCallPage({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.roomUid,
    required this.hangUp,
  });

  @override
  InVideoCallPageState createState() => InVideoCallPageState();
}

class InVideoCallPageState extends State<InVideoCallPage> {
  final callRepo = GetIt.I.get<CallRepo>();
  final width = 100.0;
  final height = 150.0;
  Offset position = const Offset(10, 30);

  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose(){
  //   super.dispose();
  //   callRepo.disposeRenderer();
  // }

  @override
  Widget build(BuildContext context) {
    final x = MediaQuery.of(context).size.width;
    final y = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        FutureBuilder<Avatar?>(
          future: _avatarRepo.getLastAvatar(widget.roomUid),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.fileId != null) {
              return FutureBuilder<String?>(
                future: _fileRepo.getFile(
                  snapshot.data!.fileId!,
                  snapshot.data!.fileName!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return FadeAudioCallBackground(
                      image: FileImage(File(snapshot.data!)),
                    );
                  } else {
                    return const FadeAudioCallBackground(
                      image: AssetImage("assets/images/no-profile-pic.png"),
                    );
                  }
                },
              );
            } else {
              return const FadeAudioCallBackground(
                image: AssetImage("assets/images/no-profile-pic.png"),
              );
            }
          },
        ),
        StreamBuilder<bool>(
          stream: MergeStream([
            callRepo.incomingSharing,
            callRepo.sharing,
          ]),
          builder: (c, s) {
            if (s.hasData && s.data!) {
              return isWindows
                  ? OrientationBuilder(
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
                              Column(
                                children: [
                                  if (s.hasData && callRepo.sharing.value)
                                    Container(
                                      margin: const EdgeInsets.all(0),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: RTCVideoView(
                                        widget.localRenderer,
                                      ),
                                    )
                                  else
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        0.0,
                                        0.0,
                                        0.0,
                                        0.0,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: RTCVideoView(
                                        widget.localRenderer,
                                        mirror: true,
                                      ),
                                    ),
                                  if (s.hasData &&
                                      callRepo.incomingSharing.value)
                                    Container(
                                      margin: const EdgeInsets.all(0),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: RTCVideoView(
                                        widget.remoteRenderer,
                                        filterQuality: FilterQuality.none,
                                      ),
                                    )
                                  else
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        0.0,
                                        0.0,
                                        0.0,
                                        0.0,
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: RTCVideoView(
                                        widget.remoteRenderer,
                                        filterQuality: FilterQuality.none,
                                        mirror: true,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Stack(
                      children: [
                        if (callRepo.sharing.value)
                          RTCVideoView(
                            widget.remoteRenderer,
                            filterQuality: FilterQuality.none,
                          )
                        else
                          RTCVideoView(
                            widget.remoteRenderer,
                            mirror: true,
                            filterQuality: FilterQuality.none,
                          ),
                        Positioned(
                          left: position.dx,
                          top: position.dy,
                          child: Draggable(
                            feedback: SizedBox(
                              width: width,
                              height: height,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: RTCVideoView(
                                  widget.localRenderer,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                            onDraggableCanceled: (velocity, offset) {
                              setState(() {
                                if (isDesktop) {
                                  position = const Offset(20, 40);
                                } else {
                                  if (offset.dx > x / 2 && offset.dy > y / 2) {
                                    position =
                                        Offset(x - width - 20, y - height - 40);
                                  }
                                  if (offset.dx < x / 2 && offset.dy > y / 2) {
                                    position = Offset(20, y - height - 40);
                                  }
                                  if (offset.dx > x / 2 && offset.dy < y / 2) {
                                    position = Offset(x - 500, 40);
                                  }
                                  if (offset.dx < x / 2 && offset.dy < y / 2) {
                                    position = const Offset(20, 40);
                                  }
                                }
                              });
                            },
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    child: RTCVideoView(
                                      widget.localRenderer,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover,
                                      mirror: true,
                                      filterQuality: FilterQuality.high,
                                    ),
                                    onTap: () {
                                      if (isAndroid) {
                                        callRepo.switching
                                            .add(!callRepo.switching.value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            } else {
              return CenterAvatarInCall(
                roomUid: widget.roomUid,
              );
            }
          },
        ),
        CallBottomRow(
          hangUp: widget.hangUp,
        ),
      ],
    );
  }
}
