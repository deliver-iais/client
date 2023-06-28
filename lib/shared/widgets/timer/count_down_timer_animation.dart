import 'dart:async';
import 'package:deliver/localization/i18n.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CountdownTimerAnimation extends StatefulWidget {
  final int endIntTime;
  final Color? color;

  const CountdownTimerAnimation({
    super.key,
    required this.endIntTime,
    required this.color,
  });

  @override
  State<CountdownTimerAnimation> createState() => _CountdownTimerAnimation();
}

class _CountdownTimerAnimation extends State<CountdownTimerAnimation> {
  final _i18n = GetIt.I.get<I18N>();
  late Duration _timeLeft = Duration.zero;
  late Timer _timer;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    _endTime = DateTime.fromMillisecondsSinceEpoch(widget.endIntTime);
    final difference = _endTime.difference(now);

    setState(() {
      _timeLeft = difference;
    });
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = _endTime.difference(DateTime.now());
        if (_timeLeft.inSeconds <= 0) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_timeLeft.inSeconds > 0) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlipClockPlus.reverseCountdown(
              separator: Text(
                ":",
                style: TextStyle(
                  fontSize: 26.0,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              width: 26,
              height: 32,
              duration: _timeLeft,
              backgroundColor: theme.colorScheme.primaryContainer,
              digitSize: 26,
              flipDirection: FlipDirection.up,
              digitColor: theme.colorScheme.onPrimaryContainer,
              spacing: const EdgeInsets.symmetric(horizontal: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              daysLabelStr: _i18n["days"],
              hoursLabelStr: _i18n["hours"],
              minutesLabelStr: _i18n["minutes"],
              secondsLabelStr: _i18n["seconds"],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
