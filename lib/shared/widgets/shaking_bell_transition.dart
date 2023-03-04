import 'dart:async';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class ShakingBellTransition extends StatefulWidget {
  final Widget child;

  const ShakingBellTransition({
    super.key,
    required this.child,
  });

  @override
  ShakingBellTransitionState createState() => ShakingBellTransitionState();
}

class ShakingBellTransitionState extends State<ShakingBellTransition>
    with SingleTickerProviderStateMixin {
  final _isBellMode = BehaviorSubject.seeded(false);
  DateTime? lastTimeBellAnimationPlay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (lastTimeBellAnimationPlay == null ||
        DateTime.now().difference(lastTimeBellAnimationPlay!).inSeconds >= 10) {
      Timer(const Duration(milliseconds: 200), () {
        lastTimeBellAnimationPlay = DateTime.now();
        _isBellMode.add(true);
      });
      Timer(const Duration(milliseconds: 2000), () {
        _isBellMode.add(false);
        lastTimeBellAnimationPlay = DateTime.now();
      });
    }
    return StreamBuilder<bool>(
      stream: _isBellMode,
      builder: (context, snapshot) {
        final isBellMode = snapshot.data ?? false;
        return SizedBox(
          height: 30,
          width: 40,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: child,
            ),
            child: !isBellMode
                ? Container(child: widget.child)
                : const BellWs(key: ValueKey('icon2')),
          ),
        );
      },
    );
  }
}

class BellWs extends StatelessWidget {
  const BellWs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          transform: Matrix4.translationValues(1.5, 1, 0),
          child: Ws.asset(
            "assets/animations/silent_unmute.ws",
            width: 30,
            height: 29,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.color(
                  const ['**'],
                  value: theme.colorScheme.surface,
                ),
                ValueDelegate.strokeColor(
                  const ['**'],
                  value: theme.colorScheme.surface,
                ),
              ],
            ),
          ),
        ),
        Ws.asset(
          "assets/animations/silent_unmute.ws",
          width: 25,
          height: 25,
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                const ['**'],
                value: theme.colorScheme.error,
              ),
              ValueDelegate.strokeColor(
                const ['**'],
                value: theme.colorScheme.error,
              ),
            ],
          ),
        )
      ],
    );
  }
}
