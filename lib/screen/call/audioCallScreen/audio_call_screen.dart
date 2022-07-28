import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

import '../../../shared/widgets/animated_gradient.dart';

class AudioCallScreen extends StatefulWidget {
  final Uid roomUid;
  final String callStatus;
  final String callStatusOnScreen;
  final void Function() hangUp;
  final bool isIncomingCall;

  const AudioCallScreen({
    super.key,
    required this.roomUid,
    required this.callStatus,
    required this.callStatusOnScreen,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  AudioCallScreenState createState() => AudioCallScreenState();
}

class AudioCallScreenState extends State<AudioCallScreen>
    with TickerProviderStateMixin {
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

  List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.yellow;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

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
            AnimatedGradient(),
            Column(
              children: [
                if (widget.callStatus == "Connected")
                  StreamBuilder<CallTimer>(
                    stream: callRepo.callTimer,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: callTimerWidget(snapshot.data!));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Directionality(
                      textDirection: _i18n.isPersian
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.callStatusOnScreen,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (widget.callStatus == "Connecting" ||
                              widget.callStatus == "Reconnecting" ||
                              widget.callStatus == "Ringing" ||
                              widget.callStatus == "Calling")
                            const DotAnimation()
                        ],
                      ),
                    ),
                  ),
                CenterAvatarInCall(
                  roomUid: widget.roomUid,
                ),
                if (widget.callStatus == "Ended")
                  FadeTransition(
                    opacity: _repeatEndCallAnimationController,
                    child: callRepo.callTimer.value.seconds == 0 &&
                            callRepo.callTimer.value.minutes == 0 &&
                            callRepo.callTimer.value.hours == 0
                        ? Text(
                            widget.callStatusOnScreen,
                            style: const TextStyle(color: Colors.white70),
                          )
                        : callTimerWidget(callRepo.callTimer.value),
                  )
              ],
            ),
            if (widget.callStatus == "Ended")
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
