import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_bottom_row.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;
  final bool isAccepted;

  const AudioCallScreen(
      {Key? key, required this.roomUid, required this.isAccepted})
      : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}
//TODO 1.BEEP SOUND 2.MUTE SOUND AND SPEAKER 3.TIMER PROBLEM 4.REFACTOR MY CODE 5.OPEN ROOM WHEN CALL END

class _AudioCallScreenState extends State<AudioCallScreen> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  @override
  void initState() {
    initRenderer();
    startCall();
    super.initState();
  }

  initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
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
    } else {
       await callRepo.startCall(widget.roomUid, false);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        FutureBuilder<Avatar?>(
            future: _avatarRepo.getLastAvatar(widget.roomUid, false),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return FutureBuilder<File?>(
                    future: _fileRepo.getFile(
                        snapshot.data!.fileId!, snapshot.data!.fileName!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return FadeAudioCallBackground(
                          image: FileImage(snapshot.data!),
                        );
                      } else {
                        return const FadeAudioCallBackground(
                          image: AssetImage("assets/images/no-profile-pic.png"),
                        );
                      }
                    });
              } else {
                return const FadeAudioCallBackground(
                  image: AssetImage("assets/images/no-profile-pic.png"),
                );
              }
            }),
        Column(
          children: [
            CenterAvatarInCall(
              roomUid: widget.roomUid,
            ),
            StreamBuilder(
                stream: callRepo.callingStatus,
                builder: (context, snapshot) {
                  switch (snapshot.data) {
                    case CallStatus.IS_RINGING:
                      return const Text("Ringing...",
                          style: TextStyle(color: Colors.white70));
                      break;
                    case CallStatus.CONNECTING:
                    case CallStatus.CREATED:
                      return const Text("Calling....",
                          style: TextStyle(color: Colors.white70));
                      break;
                    case CallStatus.ENDED:
                      _routingService.pop();
                      return SizedBox.shrink();

                      break;
                    case CallStatus.CONNECTED:
                      return Text("$hours:$minutes:$seconds",
                          style: TextStyle(color: Colors.white70));
                      break;
                    default:
                      {
                        return const Text("Connecting..",
                            style: TextStyle(color: Colors.white70));
                      }
                      break;
                  }
                })
          ],
        ),
        AudioCallBottomRow(
          hangUp: _hangUp,
        )
      ],
    ));
  }

  _hangUp() async {
    await _routingService.pop();
    await callRepo.endCall();
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }
}
