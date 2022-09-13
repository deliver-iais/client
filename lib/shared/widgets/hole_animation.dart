import 'package:flutter/material.dart';

class HoleAnimation extends StatefulWidget {
  const HoleAnimation({
    super.key,
  });

  @override
  HoleAnimationState createState() => HoleAnimationState();
}

class HoleAnimationState extends State<HoleAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: 40).animate(_animationController);
    _animationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HoleAnimatedBackground(
      animation: _animation,
    );
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
          holeSize: 30 * (animation.value),
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

