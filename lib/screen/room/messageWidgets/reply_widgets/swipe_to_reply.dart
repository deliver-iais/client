import 'dart:math' as math;
import 'dart:math';

import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Swipe extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final double threshold;

  const Swipe({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.threshold = 64.0,
  });

  @override
  State<StatefulWidget> createState() {
    return _SwipeState();
  }
}

class _SwipeState extends State<Swipe> with TickerProviderStateMixin {
  double _dragExtent = 0.0;
  late AnimationController _moveController;
  late Animation<Offset> _moveAnimation;
  bool showRightIcon = false;
  double iconScale = 0;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _moveAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
            .animate(_moveController);

    const controllerValue = 0.0;
    _moveController.animateTo(controllerValue);
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.onSwipeLeft == null) {
      return;
    }

    final delta = details.primaryDelta;
    final oldDragExtent = _dragExtent;
    _dragExtent += delta!;

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {
        _updateMoveAnimation();
      });
    }

    final movePastThresholdPixels = widget.threshold;
    var newPos = _dragExtent.abs() / context.size!.width;

    if (_dragExtent.abs() > movePastThresholdPixels) {
      // how many "thresholds" past the threshold we are. 1 = the threshold 2
      // = two thresholds.
      final n = _dragExtent.abs() / movePastThresholdPixels;

      // Take the number of thresholds past the threshold, and reduce this
      // number
      final reducedThreshold = math.pow(n, 0.3);

      final adjustedPixelPos = movePastThresholdPixels * reducedThreshold;
      newPos = adjustedPixelPos / context.size!.width;
    }

    // Range control
    final rangeValue = min(max(_dragExtent, -50), 0);

    setState(() {
      iconScale = rangeValue.abs() / 50;
    });

    if (rangeValue <= -50) {
      if (!showRightIcon) {
        lightVibrate();
        setState(() {
          showRightIcon = true;
        });
      }
    } else if (rangeValue >= -45) {
      if (showRightIcon) {
        setState(() {
          showRightIcon = false;
        });
      }
    }
    if (_dragExtent < 0) _moveController.value = newPos;
  }

  void _handleDragEnd(DragEndDetails details) {
    _moveController.animateTo(0.0, duration: const Duration(milliseconds: 200));
    if (_dragExtent < -50) {
      iconScale = 0;
      showRightIcon = false;
      setState(() {});
      widget.onSwipeLeft?.call();
    }

    _dragExtent = 0.0;
  }

  void _updateMoveAnimation() {
    final end = _dragExtent.sign;
    _moveAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.0), end: Offset(end, 0.0))
            .animate(_moveController);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      AnimatedOpacity(
        opacity: showRightIcon ? 1 : iconScale * 0.3,
        duration: AnimationSettings.normal,
        child: AnimatedContainer(
          width: 46,
          height: 46,
          padding: const EdgeInsetsDirectional.all(p8),
          margin: const EdgeInsetsDirectional.all(p8),
          decoration: BoxDecoration(
            color: showRightIcon
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.8)
                : Theme.of(context).colorScheme.primaryContainer.withOpacity(0),
            borderRadius: mainBorder,
          ),
          duration: AnimationSettings.slow,
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedScale(
              scale: iconScale,
              duration: AnimationSettings.normal,
              child: Icon(
                CupertinoIcons.reply,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
      SlideTransition(
        position: _moveAnimation,
        child: widget.child,
      ),
    ];

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.centerRight,
        fit: StackFit.passthrough,
        children: children,
      ),
    );
  }
}
