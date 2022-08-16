
import 'package:deliver/shared/constants.dart';
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
      duration: SLOW_ANIMATION_DURATION,
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
