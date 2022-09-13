import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/shared/widgets/dot_animation/dot_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallStatusWidget extends StatefulWidget {
  final CallStatus callStatus;
  final String callStatusOnScreen;

  const CallStatusWidget({
    super.key,
    required this.callStatus,
    required this.callStatusOnScreen,
  });

  @override
  State<CallStatusWidget> createState() => _CallStatusWidgetState();
}

class _CallStatusWidgetState extends State<CallStatusWidget>
    with TickerProviderStateMixin {
  final _callRepo = GetIt.I.get<CallRepo>();
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
  void dispose() {
    _repeatEndCallAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.callStatus == CallStatus.CONNECTED) {
      return StreamBuilder<CallTimer>(
        initialData: CallTimer(0, 0, 0),
        stream: _callRepo.callTimer,
        builder: (context, snapshot) {
          return callTimerWidget(
            theme,
            snapshot.data!,
            isEnd: false,
          );
        },
      );
    } else {
      return Directionality(
        textDirection: _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          mainAxisSize:MainAxisSize.min ,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.callStatus != CallStatus.ENDED)
              Text(
                widget.callStatusOnScreen,
                style:
                    theme.textTheme.titleLarge!.copyWith(color: Colors.white70),
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
                        widget.callStatusOnScreen,
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
              ),
            if (widget.callStatus == CallStatus.CONNECTING ||
                widget.callStatus == CallStatus.RECONNECTING ||
                widget.callStatus == CallStatus.IS_RINGING ||
                widget.callStatus == CallStatus.CREATED)
              const DotAnimation()
          ],
        ),
      );
    }
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
      mainAxisSize:MainAxisSize.min ,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.phone_fill,
          size: 25,
          color: isEnd ? theme.errorColor : theme.colorScheme.surface,
        ),
        const SizedBox(
          width: 8,
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
}
