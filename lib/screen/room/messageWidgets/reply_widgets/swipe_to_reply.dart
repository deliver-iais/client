import 'dart:math' as math;

import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Swipe extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final double threshold;

  const Swipe({
    Key? key,
    required this.child,
    this.onSwipeLeft,
    this.threshold = 64.0,
  }) : super(key: key);

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
    if (_dragExtent < -50) {
      if (showRightIcon == false) {
        vibrate(duration: 50);
        setState(() {
          showRightIcon = true;
        });
      }
    } else {
      if (showRightIcon == true) {
        vibrate(duration: 50);
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
        opacity: showRightIcon ? 1 : 0,
        duration: ANIMATION_DURATION,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedScale(
              scale: showRightIcon ? 1 : 0,
              duration: ANIMATION_DURATION,
              child: Icon(
                CupertinoIcons.reply,
                color: Theme.of(context).iconTheme.color,
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
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: children,
      ),
    );
  }
}
