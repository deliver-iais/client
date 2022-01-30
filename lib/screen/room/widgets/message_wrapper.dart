import 'dart:math';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final bool isSender;
  final bool isFirstMessageInGroupedMessages;

  const MessageWrapper(
      {Key? key,
      required this.child,
      required this.isSender,
      this.isFirstMessageInGroupedMessages = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extraThemeData = ExtraTheme.of(context);
    final background = extraThemeData.messageBackground(isSender);

    var border = messageBorder;

    if (isFirstMessageInGroupedMessages) {
      if (isSender) {
        border = border.copyWith(
            topRight: const Radius.circular(4),
            topLeft: const Radius.circular(16));
      } else {
        border = border.copyWith(
            topRight: const Radius.circular(16),
            topLeft: const Radius.circular(4));
      }
    }

    return Container(
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2)
          .copyWith(top: isFirstMessageInGroupedMessages ? 16 : 4),
      decoration: BoxDecoration(
        borderRadius: border,
        color: background,
      ),
      child: child,
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
