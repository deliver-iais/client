import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/services/event_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:rxdart/rxdart.dart';

class CountDownTimer extends StatefulWidget {
  final int timeStamp;
  final BehaviorSubject<bool>? timeStampFired;

  const CountDownTimer({
    super.key,
    required this.timeStamp,
    this.timeStampFired,
  });

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController _repeatEndCallAnimationController;
  static final _eventService = GetIt.I.get<EventService>();
  Timer? timer;
  double fontSize = 10.0;

  @override
  void initState() {
    _initRepeatEndCallAnimation();
    _startEventTimer();
    super.initState();
  }

  void _initRepeatEndCallAnimation() {
    _repeatEndCallAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _repeatEndCallAnimationController.repeat(reverse: true);
  }

  void _startEventTimer() {
    final remindingTime = _calculateRemindingTime();
    // check isTimeStampFired
    if (remindingTime.isNegative && widget.timeStampFired != null) {
      widget.timeStampFired?.add(true);
    } else {
      _eventService.addCountTimer(
        CountTimer(
          remindingTime.inSeconds.remainder(60),
          remindingTime.inMinutes.remainder(60),
          remindingTime.inHours.remainder(24),
          days: remindingTime.inDays,
        ),
      );
      final eventTimer = _eventService.eventTimer;

      if (!(timer != null && timer!.isActive)) {
        const oneSec = Duration(seconds: 1);
        timer = Timer.periodic(oneSec, (timer) {
          final remindingTime = _calculateRemindingTime();
          if (remindingTime.isNegative && widget.timeStampFired != null) {
            widget.timeStampFired?.add(true);
            timer.cancel();
          } else {
            eventTimer.value.seconds = eventTimer.value.seconds - 1;
            if (eventTimer.value.seconds < 0) {
              eventTimer.value.minutes -= 1;
              eventTimer.value.seconds = 59;
              if (eventTimer.value.minutes < 0) {
                eventTimer.value.hours -= 1;
                eventTimer.value.minutes = 59;
                if (eventTimer.value.hours < 0) {
                  eventTimer.value.days -= 1;
                  eventTimer.value.hours = 23;
                }
              }
            }
            eventTimer.add(
              CountTimer(
                eventTimer.value.seconds,
                eventTimer.value.minutes,
                eventTimer.value.hours,
                days: eventTimer.value.days,
              ),
            );
          }
        });
      }
    }
  }

  Duration _calculateRemindingTime() {
    final date = DateTime.fromMillisecondsSinceEpoch(widget.timeStamp);
    final remindingTime = date.difference(clock.now());
    return remindingTime;
  }

  @override
  void dispose() {
    _repeatEndCallAnimationController.dispose();
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: StreamBuilder<CountTimer>(
        initialData: CountTimer(0, 0, 0),
        stream: _eventService.getEventTimerStream(),
        builder: (context, snapshot) {
          return AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: detectBackGroundColor(snapshot.data!),
            ),
            clipBehavior: Clip.hardEdge,
            duration: SLOW_ANIMATION_DURATION,
            width: 130,
            height: 30,
            child: !(snapshot.data!.days == 0 &&
                    snapshot.data!.hours == 0 &&
                    snapshot.data!.minutes == 0 &&
                    snapshot.data!.seconds < 10)
                ? countTimerWidget(
                    theme,
                    snapshot.data!,
                  )
                : FadeTransition(
                    opacity: _repeatEndCallAnimationController,
                    child: countTimerWidget(
                      theme,
                      snapshot.data!,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Row countTimerWidget(ThemeData theme, CountTimer countTimer) {
    var days = countTimer.days.toString();
    var hours = countTimer.hours.toString();
    var minutes = countTimer.minutes.toString();
    var seconds = countTimer.seconds.toString();
    days = (days.length != 2 ? '0$days' : days).toPersianDigit();
    hours = (hours.length != 2 ? '0$hours' : hours).toPersianDigit();
    minutes = (minutes.length != 2 ? '0$minutes' : minutes).toPersianDigit();
    seconds = (seconds.length != 2 ? '0$seconds' : seconds).toPersianDigit();
    return Row(
      key: const Key("timer"),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              'ثانیه',
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
              ),
            ),
            AnimatedSwitchWidget(
              child: Text(
                seconds,
                key: ValueKey(countTimer.seconds),
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 11,
          child: Column(
            children: [
              const SizedBox(
                height: 13,
              ),
              Text(
                "  :",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              'دقیقه',
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
              ),
            ),
            AnimatedSwitchWidget(
              child: Text(
                minutes,
                key: ValueKey(countTimer.minutes),
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 11,
          child: Column(
            children: [
              const SizedBox(
                height: 13,
              ),
              Text(
                ":",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              'ساعت',
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
              ),
            ),
            AnimatedSwitchWidget(
              child: Text(
                hours,
                key: ValueKey(countTimer.hours),
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 11,
          child: Column(
            children: [
              const SizedBox(
                height: 13,
              ),
              Text(
                ":",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              'روز',
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
              ),
            ),
            AnimatedSwitchWidget(
              child: Text(
                days,
                key: ValueKey(countTimer.days),
                style: theme.textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color detectBackGroundColor(CountTimer callTimer) {
    if (callTimer.days > 0) {
      return backgroundColorCard;
    } else if (callTimer.hours > 0) {
      return Colors.blueAccent;
    } else if (callTimer.minutes > 0) {
      return Colors.orange;
    } else {
      return Colors.deepOrange;
    }
  }
}
