import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/dot_animation/loading_dot_animation/delay_tween.dart';
import 'package:flutter/material.dart';

class LoadingDotAnimation extends StatefulWidget {
  final Color dotsColor;

  const LoadingDotAnimation({super.key, this.dotsColor = Colors.white70});

  @override
  State<LoadingDotAnimation> createState() => _LoadingDotAnimationState();
}

class _LoadingDotAnimationState extends State<LoadingDotAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(p2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          return ScaleTransition(
            scale: DelayTween(begin: 0.5, end: 1.0, delay: i * .2)
                .animate(_controller),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: SizedBox.fromSize(
                size: const Size.square(4),
                child: _itemBuilder(i),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _itemBuilder(int index) => DecoratedBox(
        decoration: BoxDecoration(
          color: widget.dotsColor,
          shape: BoxShape.circle,
        ),
      );
}
