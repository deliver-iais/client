import 'dart:math' as math;

import 'package:flutter/material.dart';

double deg2rad(double deg) => deg * math.pi / 180;

class GradiantCircleProgressBar extends CustomPainter {
  /// ring/border thickness, default  it will be 8px [borderThickness].
  final double borderThickness;
  final double progressValue;
  final Color inactiveColor ;
  final List<Color> colors;

  GradiantCircleProgressBar({
    this.borderThickness = 8.0,
    required this.progressValue,
    required this.colors,
    required this.inactiveColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rect =
    Rect.fromCenter(center: center, width: size.width, height: size.height);

    final paint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness;

    //grey background
    canvas.drawArc(
      rect,
      deg2rad(0),
      deg2rad(360),
      false,
      paint,
    );

    final progressBarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness
      ..shader =  LinearGradient(
        colors:colors,
      ).createShader(rect);
    canvas.drawArc(
      rect,
      deg2rad(-90),
      deg2rad(360 * progressValue),
      false,
      progressBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}