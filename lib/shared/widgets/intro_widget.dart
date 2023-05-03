import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
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
                Flexible(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: material.LinearGradient(
                        colors: [
                          Color(0xff23FFF7),
                          Color(0xff0799DF),
                        ],
                        begin: Alignment.topLeft,
                      ),
                    ),
                    child: const RiveAnimation.asset(
                      'assets/animations/weather_icon.riv',
                      fit: BoxFit.contain,
                    ),
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
