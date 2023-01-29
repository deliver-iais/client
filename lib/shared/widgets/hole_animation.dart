import 'dart:ui';

import 'package:deliver/services/call_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HoleAnimation extends StatefulWidget {
  const HoleAnimation({
    super.key,
  });

  @override
  HoleAnimationState createState() => HoleAnimationState();
}

class HoleAnimationState extends State<HoleAnimation>
    with SingleTickerProviderStateMixin {
  final _callService = GetIt.I.get<CallService>();
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    _callService.isHole = true;
    super.dispose();
  }

  @override
  void initState() {
    final width = window.physicalSize.longestSide / window.devicePixelRatio;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation =
        Tween<double>(begin: 0, end: 2 * width).animate(_animationController);
    _animationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_callService.isHole) {
      final width = window.physicalSize.longestSide / window.devicePixelRatio;
      return Center(
        child: CustomPaint(
          painter: HolePainter(
            color: Colors.black12,
            holeSize: (width * 2),
          ),
        ),
      );
    } else {
      return HoleAnimatedBackground(
        animation: _animation,
      );
    }
  }
}

class HoleAnimatedBackground extends AnimatedWidget {
  const HoleAnimatedBackground({
    super.key,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Center(
      child: CustomPaint(
        painter: HolePainter(
          color: Colors.black12,
          holeSize: (animation.value),
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  HolePainter({
    required this.color,
    required this.holeSize,
  });

  Color color;

  double holeSize;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = holeSize / 2;

    final outerCircleRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final halfTransparentRing = Path()
      ..addOval(outerCircleRect)
      ..close();

    canvas.drawPath(
      halfTransparentRing,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
