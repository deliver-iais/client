import 'dart:math' as math;

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
        duration: const Duration(milliseconds: 200), vsync: this);
    _moveAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0))
            .animate(_moveController);

    var controllerValue = 0.0;
    _moveController.animateTo(controllerValue);
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var delta = details.primaryDelta;
    var oldDragExtent = _dragExtent;
    _dragExtent += delta!;

    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {
        _updateMoveAnimation();
      });
    }

    var movePastThresholdPixels = widget.threshold;
    var newPos = _dragExtent.abs() / context.size!.width;

    if (_dragExtent.abs() > movePastThresholdPixels) {
      // how many "thresholds" past the threshold we are. 1 = the threshold 2
      // = two thresholds.
      var n = _dragExtent.abs() / movePastThresholdPixels;

      // Take the number of thresholds past the threshold, and reduce this
      // number
      var reducedThreshold = math.pow(n, 0.3);

      var adjustedPixelPos = movePastThresholdPixels * reducedThreshold;
      newPos = adjustedPixelPos / context.size!.width;
    }
    if (_dragExtent < -50) {
      showRightIcon = true;
      setState(() {});
    } else {
      showRightIcon = false;
      setState(() {});
    }
    if (_dragExtent < 0) _moveController.value = newPos;
  }

  void _handleDragEnd(DragEndDetails details) {
    _moveController.animateTo(0.0, duration: const Duration(milliseconds: 200));
    if (_dragExtent < -50) {
      showRightIcon = false;
      setState(() {});
      if (widget.onSwipeLeft != null) {
        widget.onSwipeLeft!();
      }
    }

    _dragExtent = 0.0;
  }

  void _updateMoveAnimation() {
    var end = _dragExtent.sign;
    _moveAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.0), end: Offset(end, 0.0))
            .animate(_moveController);
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      showRightIcon
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.reply,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            )
          : const SizedBox.shrink(),
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
