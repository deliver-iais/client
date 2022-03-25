import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;
  final String callStatus;
  final Function hangUp;
  final bool isIncomingCall;

  const AudioCallScreen(
      {Key? key,
      required this.roomUid,
      required this.callStatus,
      required this.hangUp,
      this.isIncomingCall = false})
      : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final callRepo = GetIt.I.get<CallRepo>();
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      FutureBuilder<Avatar?>(
          future: _avatarRepo.getLastAvatar(widget.roomUid, false),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.fileId != null) {
              return FutureBuilder<String?>(
                  future: _fileRepo.getFile(
                      snapshot.data!.fileId!, snapshot.data!.fileName!),
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
          if (widget.callStatus == "Connected")
            StreamBuilder<CallTimer>(
                stream: callRepo.callTimer,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return callTimerWidget(snapshot.data!);
                  } else {
                    return const SizedBox.shrink();
                  }
                })
          else if (widget.callStatus == "Ended")
            FadeTransition(
                opacity: _animationController,
                child: callRepo.callTimer.value.seconds == 0 &&
                        callRepo.callTimer.value.minutes == 0 &&
                        callRepo.callTimer.value.hours == 0
                    ? Text(widget.callStatus,
                        style: const TextStyle(color: Colors.white70))
                    : callTimerWidget(callRepo.callTimer.value))
          else
            Text(widget.callStatus,
                style: const TextStyle(color: Colors.white70))
        ],
      ),
      widget.callStatus == "Ended"
          ? Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Lottie.asset('assets/animations/end_of_call.json',
                    width: 150),
              ))
          : CallBottomRow(
              hangUp: widget.hangUp,
              isIncomingCall: widget.isIncomingCall,
            ),
    ]));
  }

  Text callTimerWidget(CallTimer callTimer) {
    String callHour = callTimer.hours.toString();
    String callMin = callTimer.minutes.toString();
    String callSecond = callTimer.seconds.toString();
    callHour = callHour.length != 2 ? '0' + callHour : callHour;
    callMin = callMin.length != 2 ? '0' + callMin : callMin;
    callSecond = callSecond.length != 2 ? '0' + callSecond : callSecond;
    return Text(
      callHour + ':' + callMin + ':' + callSecond,
      style: const TextStyle(
        color: Colors.white54,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
