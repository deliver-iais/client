import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/loading_dot_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class CallStatusWidget extends StatefulWidget {
  final CallStatus callStatus;
  final bool isIncomingCall;

  const CallStatusWidget({
    super.key,
    required this.callStatus,
    this.isIncomingCall = false,
  });

  @override
  State<CallStatusWidget> createState() => _CallStatusWidgetState();
}

class _CallStatusWidgetState extends State<CallStatusWidget>
    with TickerProviderStateMixin {
  final _logger = GetIt.I.get<Logger>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _i18n = GetIt.I.get<I18N>();

  final fontSize = isMobileDevice ? 14.0 : 16.0;

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
  void dispose() {
    _repeatEndCallAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: detectBackGroundColor(widget.callStatus),
      ),
      clipBehavior: Clip.hardEdge,
      duration: SUPER_ULTRA_SLOW_ANIMATION_DURATION,
      width: widget.callStatus == CallStatus.CONNECTED
          ? 120
          : (isMobileDevice ? 150 : 170),
      height: 30,
      child: (widget.callStatus == CallStatus.CONNECTED)
          ? StreamBuilder<CallTimer>(
              initialData: CallTimer(0, 0, 0),
              stream: _callRepo.callTimer,
              builder: (context, snapshot) {
                return StreamBuilder<bool>(
                  stream: _callRepo.incomingCallOnHold,
                  builder: (context, isCallOnHold) {
                    return AnimatedSwitcher(
                      duration: SUPER_SLOW_ANIMATION_DURATION,
                      child: (isCallOnHold.data ?? false)
                          ? Text(
                              _i18n.get("call_on_hold"),
                              style: theme.textTheme.titleLarge!.copyWith(
                                color: theme.colorScheme.surface,
                                fontStyle: FontStyle.italic,
                                fontSize: fontSize,
                              ),
                              key: const Key("hold_on"),
                            )
                          : callTimerWidget(
                              theme,
                              snapshot.data!,
                              isEnd: false,
                            ),
                    );
                  },
                );
              },
            )
          : Directionality(
              textDirection:
                  _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.callStatus != CallStatus.ENDED)
                    Text(
                      callStatusOnScreen(widget.callStatus),
                      style: theme.textTheme.titleLarge!
                          .copyWith(color: Colors.white70, fontSize: fontSize),
                    )
                  else
                    FadeTransition(
                      opacity: _repeatEndCallAnimationController,
                      child: (_callRepo.isConnected)
                          ? Directionality(
                              textDirection: TextDirection.ltr,
                              child: callTimerWidget(
                                theme,
                                _callRepo.callTimer.value,
                                isEnd: true,
                              ),
                            )
                          : Text(
                              callStatusOnScreen(widget.callStatus),
                              style: theme.textTheme.titleLarge!.copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                              ),
                            ),
                    ),
                  if (widget.callStatus == CallStatus.CONNECTING ||
                      widget.callStatus == CallStatus.RECONNECTING ||
                      widget.callStatus == CallStatus.IS_RINGING ||
                      widget.callStatus == CallStatus.CREATED)
                    const LoadingDotAnimation()
                ],
              ),
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
      key: const Key("timer"),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _callRepo.isVideo
              ? CupertinoIcons.videocam
              : CupertinoIcons.phone_fill,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          '$callHour:$callMin:$callSecond',
          style: theme.textTheme.titleLarge!.copyWith(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  Color detectBackGroundColor(CallStatus callStatus) {
    switch (callStatus) {
      case CallStatus.CONNECTED:
        return backgroundColorCard;

      case CallStatus.CONNECTING:
      case CallStatus.DISCONNECTED:
      case CallStatus.RECONNECTING:
        return Colors.orange;

      case CallStatus.FAILED:
      case CallStatus.NO_ANSWER:
      case CallStatus.ENDED:
      case CallStatus.BUSY:
      case CallStatus.DECLINED:
        return Colors.red;

      case CallStatus.ACCEPTED:
      case CallStatus.NO_CALL:
      case CallStatus.IS_RINGING:
      case CallStatus.CREATED:
        return Colors.blueAccent;
    }
  }

  String callStatusOnScreen(CallStatus callStatus) {
    _logger.i("callStatus : $callStatus");
    switch (callStatus) {
      case CallStatus.CONNECTED:
        return _i18n.get("call_connected");
      case CallStatus.DISCONNECTED:
        return _i18n.get("call_dis_connected");
      case CallStatus.CONNECTING:
        return _i18n.get("call_connecting");
      case CallStatus.RECONNECTING:
        return _i18n.get("call_reconnecting");
      case CallStatus.FAILED:
        return _i18n.get("call_connection_failed");
      case CallStatus.IS_RINGING:
        return _i18n.get("call_ringing");
      case CallStatus.NO_ANSWER:
        return _i18n.get("call_user_not_answer");
      case CallStatus.CREATED:
        return widget.isIncomingCall
            ? _i18n.get("call_incoming")
            : _i18n.get("call_calling");
      case CallStatus.ENDED:
        return _i18n.get("call_ended");
      case CallStatus.BUSY:
        return "${_i18n.get("call_busy")}....";
      case CallStatus.DECLINED:
        return "${_i18n.get("call_declined")}....";
      case CallStatus.ACCEPTED:
        unawaited(_callRepo.cancelCallNotification());
        return _i18n.get("call_accepted");
      case CallStatus.NO_CALL:
        return "";
    }
  }
}
