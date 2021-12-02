import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/call_bottom_row.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;
  final String callStatus;
  final Function hangUp;

  const AudioCallScreen(
      {Key? key,
      required this.roomUid,
      required this.callStatus,
      required this.hangUp})
      : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}
//TODO 1.BEEP SOUND 2.MUTE SOUND AND SPEAKER 3.TIMER PROBLEM 4.REFACTOR MY CODE 5.OPEN ROOM WHEN CALL END

class _AudioCallScreenState extends State<AudioCallScreen> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final callRepo = GetIt.I.get<CallRepo>();

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      FutureBuilder<Avatar?>(
          future: _avatarRepo.getLastAvatar(widget.roomUid, false),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.fileId != null) {
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
          Text(widget.callStatus, style: TextStyle(color: Colors.white70)),
        ],
      ),
      CallBottomRow(hangUp: widget.hangUp,isVideoCall: false,)
    ]));
  }
}
