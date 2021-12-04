import 'dart:math';

import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final bool isSent;

  const MessageWrapper({Key? key, required this.child, required this.isSent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(10);
    const border = BorderRadius.all(radius);
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: const BoxDecoration(borderRadius: border, boxShadow: [
          BoxShadow(
              color: Colors.black38, blurRadius: 0.5, offset: Offset(0, 0.5))
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
                        foregroundPainter: OPainter(isSent
                            ? ExtraTheme.of(context).sentMessageBox
                            : ExtraTheme.of(context).receivedMessageBox),
                      ))
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            foregroundPainter: OPainter(isSent
                                ? ExtraTheme.of(context).sentMessageBox
                                : ExtraTheme.of(context).receivedMessageBox),
                          )),
                    ),
            ),
            ClipRRect(
                borderRadius: border,
                child: Container(
                    color: isSent
                        ? ExtraTheme.of(context).sentMessageBox
                        : ExtraTheme.of(context).receivedMessageBox,
                    child: child)),
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

    path.moveTo(10, 5);

    path.arcToPoint(
      const Offset(-4, 0),
      radius: const Radius.circular(20),
      clockwise: false,
    );

    path.arcToPoint(
      const Offset(0, 12),
      radius: const Radius.circular(15),
      clockwise: true,
    );

    path.lineTo(10, 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
