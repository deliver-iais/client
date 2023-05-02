import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class IntroWidget extends StatelessWidget {
  final Widget child;

  const IntroWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  curve: Curves.ease,
                  constraints: BoxConstraints(
                    maxWidth: isLargeWidthForIntro(constraints.maxWidth)
                        ? FLUID_MAX_WIDTH
                        : size.width,
                  ),
                  duration: AnimationSettings.standard,
                  child: child,
                ),
                const Flexible(
                  child: RiveAnimation.asset(
                    'assets/animations/fun_time.riv',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
