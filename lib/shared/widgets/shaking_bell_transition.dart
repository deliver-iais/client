import 'dart:async';
import 'package:flutter/material.dart';
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
    if (lastTimeBellAnimationPlay==null || DateTime.now().difference(lastTimeBellAnimationPlay!).inSeconds >= 10) {
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
        return Positioned(
          top: !isBellMode ? 3 : -1,
          right: !isBellMode ? 0 : -6,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('icon1')
                  ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: !isBellMode
                ? widget.child
                : const BellAnimation(
                    key: ValueKey('icon2'),
                  ),
          ),
        );
      },
    );
  }
}

class BellAnimation extends StatefulWidget {
  const BellAnimation({super.key});

  @override
  BellAnimationState createState() => BellAnimationState();
}

class BellAnimationState extends State<BellAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward().then((value) => _controller.reset());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: -.1)
          .chain(CurveTween(curve: Curves.elasticIn))
          .animate(_controller),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 29,
          ),
          Icon(
            Icons.notifications,
            color: Theme.of(context).colorScheme.primary,
            size: 25,
          ),
        ],
      ),
    );
  }
}
