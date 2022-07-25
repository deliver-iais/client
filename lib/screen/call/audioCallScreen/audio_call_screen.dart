import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/call/audioCallScreen/fade_audio_call_background.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;
  final String callStatus;
  final void Function() hangUp;
  final bool isIncomingCall;

  const AudioCallScreen({
    super.key,
    required this.roomUid,
    required this.callStatus,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  AudioCallScreenState createState() => AudioCallScreenState();
}

class AudioCallScreenState extends State<AudioCallScreen>
    with TickerProviderStateMixin {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final callRepo = GetIt.I.get<CallRepo>();
  final _i18n = GetIt.I.get<I18N>();
  late AnimationController _repeatEndCallAnimationController;

  @override
  void initState() {
    _initRepeatEndCallAnimation();

    super.initState();
  }

  void _initRepeatEndCallAnimation() {
    _repeatEndCallAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _repeatEndCallAnimationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
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
            Column(
              children: [
                CenterAvatarInCall(
                  roomUid: widget.roomUid,
                ),
                if (widget.callStatus == _i18n.get("call_connected"))
                  StreamBuilder<CallTimer>(
                    stream: callRepo.callTimer,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return callTimerWidget(snapshot.data!);
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                else if (widget.callStatus == _i18n.get("call_ended"))
                  FadeTransition(
                    opacity: _repeatEndCallAnimationController,
                    child: callRepo.callTimer.value.seconds == 0 &&
                            callRepo.callTimer.value.minutes == 0 &&
                            callRepo.callTimer.value.hours == 0
                        ? Text(
                            widget.callStatus,
                            style: const TextStyle(color: Colors.white70),
                          )
                        : callTimerWidget(callRepo.callTimer.value),
                  )
                else
                  Directionality(
                    textDirection: _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.callStatus,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (widget.callStatus == _i18n.get("call_connecting") ||
                            widget.callStatus ==
                                _i18n.get("call_reconnecting") ||
                            widget.callStatus == _i18n.get("call_ringing") ||
                            widget.callStatus == _i18n.get("call_calling") ||
                            widget.callStatus == _i18n.get("call_incoming"))
                          const DotAnimation()
                      ],
                    ),
                  ),
              ],
            ),
            if (widget.callStatus == _i18n.get("call_ended"))
              Padding(
                padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Lottie.asset(
                    'assets/animations/end_of_call.json',
                    width: 150,
                  ),
                ),
              )
            else
              CallBottomRow(
                hangUp: widget.hangUp,
                isIncomingCall: widget.isIncomingCall,
              ),
          ],
        ),
      ),
    );
  }

  Text callTimerWidget(CallTimer callTimer) {
    var callHour = callTimer.hours.toString();
    var callMin = callTimer.minutes.toString();
    var callSecond = callTimer.seconds.toString();
    callHour = callHour.length != 2 ? '0$callHour' : callHour;
    callMin = callMin.length != 2 ? '0$callMin' : callMin;
    callSecond = callSecond.length != 2 ? '0$callSecond' : callSecond;
    return Text(
      '$callHour:$callMin:$callSecond',
      style: const TextStyle(
        color: Colors.white54,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  void dispose() {
    _repeatEndCallAnimationController.dispose();

    super.dispose();
  }
}
