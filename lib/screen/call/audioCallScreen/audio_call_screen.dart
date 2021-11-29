import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/audio_call_bottom_row.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;

  const AudioCallScreen({Key? key, required this.roomUid}) : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  @override
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
                      if (snapshot.hasData) {
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
            const Text("Calling", style: TextStyle(color: Colors.white70)),
          ],
        ),
        const AudioCallBottomRow()
      ],
    ));
  }
}
