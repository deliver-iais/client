import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/center_avatar_image-in-call.dart';
import 'package:deliver/shared/widgets/animated_gradient.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedGradient(isConnected: callRepo.isConnected),
          Column(
            children: [
              if (widget.callStatus == "Connected")
                StreamBuilder<CallTimer>(
                  initialData: CallTimer(0, 0, 0),
                  stream: callRepo.callTimer,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.15,
                      ),
                      child: callTimerWidget(
                        theme,
                        snapshot.data!,
                        isEnd: false,
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Directionality(
                    textDirection:
                        _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.callStatus != "Ended")
                          Text(
                            widget.callStatusOnScreen,
                            style: theme.textTheme.titleLarge!
                                .copyWith(color: Colors.white70),
                          )
                        else
                          FadeTransition(
                            opacity: _repeatEndCallAnimationController,
                            child: (callRepo.isConnected)
                                ? Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: callTimerWidget(
                                      theme,
                                      callRepo.callTimer.value,
                                      isEnd: true,
                                    ),
                                  )
                                : Text(
                                    widget.callStatusOnScreen,
                                    style: theme.textTheme.titleLarge!
                                        .copyWith(color: Colors.red),
                                  ),
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
            ],
          ),
          if (widget.callStatus != "Ended")
            CallBottomRow(
              hangUp: widget.hangUp,
              isIncomingCall: widget.isIncomingCall,
            ),
        ],
      ),
    );
  }

  Row callTimerWidget(
    ThemeData theme,
    CallTimer callTimer, {
    required bool isEnd,
  }) {
    var callHour = callTimer.hours.toString();
    var callMin = callTimer.minutes.toString();
    var callSecond = callTimer.seconds.toString();
    callHour = callHour.length != 2 ? '0$callHour' : callHour;
    callMin = callMin.length != 2 ? '0$callMin' : callMin;
    callSecond = callSecond.length != 2 ? '0$callSecond' : callSecond;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.phone_fill,
          size: 25,
          color: isEnd ? theme.errorColor : theme.colorScheme.surface,
        ),
        Text(
          '$callHour:$callMin:$callSecond',
          style: theme.textTheme.titleLarge!.copyWith(
            color: isEnd ? theme.errorColor : theme.colorScheme.surface,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _repeatEndCallAnimationController.dispose();
    super.dispose();
  }
}
