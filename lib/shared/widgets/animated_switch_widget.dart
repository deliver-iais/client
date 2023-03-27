import 'package:deliver/shared/animation_settings.dart';
import 'package:flutter/cupertino.dart';

class AnimatedSwitchWidget extends StatelessWidget {
  final Widget child;
  final Duration? duration;

  const AnimatedSwitchWidget({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? AnimationSettings.verySlow,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return RoundUpTransition(
          turns: animation,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: child,
    );
  }
}

class RoundUpTransition extends AnimatedWidget {
  /// Creates a rotation transition.
  ///
  /// The [turns] argument must not be null.
  const RoundUpTransition({
    Key? key,
    required Animation<double> turns,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.child,
  }) : super(key: key, listenable: turns);

  /// The animation that controls the rotation of the child.
  ///
  /// If the current value of the turns animation is v, the child will be
  /// rotated v * 2 * pi radians before being painted.
  Animation<double> get turns => listenable as Animation<double>;

  /// The alignment of the origin of the coordinate system around which the
  /// rotation occurs, relative to the size of the box.
  ///
  /// For example, to set the origin of the rotation to top right corner, use
  /// an alignment of (1.0, -1.0) or use [Alignment.topRight]
  final Alignment alignment;

  /// The filter quality with which to apply the transform as a bitmap operation.
  ///
  /// {@macro flutter.widgets.Transform.optional.FilterQuality}
  final FilterQuality? filterQuality;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: turns,
      child: Container(
        // transform: Matrix4.rotationX(turns.value * pi * 2),
        transform: Matrix4.translationValues(
          0,
          (1 - turns.value) *
              20 *
              (turns.status == AnimationStatus.forward ? -1 : 1),
          0,
        ),
        transformAlignment: Alignment.center,
        child: child,
      ),
    );
  }
}
