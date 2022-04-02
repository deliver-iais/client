import 'dart:math';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final String uid;
  final CustomColorScheme colorScheme;
  final bool isSender;
  final bool isFirstMessageInGroupedMessages;

  const MessageWrapper(
      {Key? key,
      required this.child,
      required this.uid,
      required this.colorScheme,
      required this.isSender,
      this.isFirstMessageInGroupedMessages = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var border = messageBorder;

    if (isFirstMessageInGroupedMessages) {
      if (isSender) {
        border = border.copyWith(topRight: Radius.zero);
      } else {
        border = border.copyWith(topLeft: Radius.zero);
      }
    }

    const width = 6.0;
    const height = 30.0;
    final color = colorScheme.primaryContainer;

    return Stack(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2)
              .copyWith(
                  top: isFirstMessageInGroupedMessages
                      ? (isSender ? 16 : 0)
                      : 2),
          decoration: BoxDecoration(
            borderRadius: border,
            color: color,
          ),
          child: child,
        ),
        if (isFirstMessageInGroupedMessages)
          Positioned(
            left: isSender ? null : 10 - width,
            right: !isSender ? null : 10 - width,
            top: isSender ? 16 : 0,
            child: !isSender
                ? CustomPaint(
                    size: const Size(width, height),
                    foregroundPainter: OPainter(color))
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: CustomPaint(
                        size: const Size(width, height),
                        foregroundPainter: OPainter(color)),
                  ),
          ),
      ],
    );
  }
}

class OPainter extends CustomPainter {
  final Color color;

  OPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path();

    final x = size.width;
    final y = size.height;

    path.moveTo(x, 0);

    path.moveTo(0, 0);

    path.arcToPoint(
      Offset(x, y),
      radius: Radius.circular(y * 2),
      clockwise: true,
    );

    path.lineTo(x, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
