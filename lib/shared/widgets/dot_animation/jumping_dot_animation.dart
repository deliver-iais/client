
import 'package:flutter/material.dart';

class JumpingDotAnimation extends StatefulWidget {
  final Color dotsColor;

  const JumpingDotAnimation({super.key, this.dotsColor = Colors.white70});

  @override
  State<JumpingDotAnimation> createState() => _JumpingDotAnimationState();
}

class _JumpingDotAnimationState extends State<JumpingDotAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotAnimationControllers;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    _initDotAnimation();
    super.initState();
  }

  void _initDotAnimation() {
    _dotAnimationControllers = List.generate(
      3,
          (index) {
        return AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        );
      },
    ).toList();

    for (var i = 0; i < 3; i++) {
      _animations.add(
        Tween<double>(begin: 0, end: -2).animate(_dotAnimationControllers[i]),
      );
    }

    for (var i = 0; i < 3; i++) {
      _dotAnimationControllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _dotAnimationControllers[i].reverse();

          if (i != 2) {
            _dotAnimationControllers[i + 1].forward();
          }
        }

        if (i == 2 && status == AnimationStatus.dismissed) {
          _dotAnimationControllers[0].forward();
        }
      });
    }

    _dotAnimationControllers.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotAnimationControllers[index],
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: DotWidget(dotsColor: widget.dotsColor),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    for (final controller in _dotAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

}
class DotWidget extends StatelessWidget {  final Color dotsColor;

const DotWidget({
  Key? key, required this.dotsColor,
}) : super(key: key);
@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(shape: BoxShape.circle, color: dotsColor),
    height:3,
    width: 3,
  );
}
}