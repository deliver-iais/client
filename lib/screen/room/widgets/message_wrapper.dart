import 'dart:math';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final bool isSent;

  const MessageWrapper({Key? key, required this.child, required this.isSent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: secondaryBorder,
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  blurRadius: 0.5,
                  offset: Offset(0, 0.5))
            ]),
        child: Stack(
          children: [
            Positioned(
              left: isSent ? null : 0,
              right: !isSent ? null : 0,
              top: 0,
              child: !isSent
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CustomPaint(
                        foregroundPainter:
                            OPainter(Theme.of(context).colorScheme.surface),
                      ))
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            foregroundPainter: OPainter(ExtraTheme.of(context)
                                .colorScheme
                                .tertiaryContainer),
                          )),
                    ),
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: secondaryBorder,
                  color: isSent
                      ? ExtraTheme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.surface,
                ),
                child: child),
          ],
        ),
      ),
    );
  }
}

class OPainter extends CustomPainter {
  final Color color;

  OPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;

    var path = Path();

    path.moveTo(20, 4);

    path.lineTo(-5, 2);

    path.arcToPoint(
      const Offset(0, 20),
      radius: const Radius.circular(40),
      clockwise: true,
    );

    path.lineTo(20, 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
