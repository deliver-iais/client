import 'package:deliver/shared/animation_settings.dart';
import 'package:flutter/cupertino.dart';

class AnimatedDeleteWidget extends StatelessWidget {
  final Widget child;

  const AnimatedDeleteWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AnimationSettings.slow,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
