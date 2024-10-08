import 'dart:math';

import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final Uid uid;
  final bool isSender;
  final bool isFirstMessageInGroupedMessages;

  const MessageWrapper({
    super.key,
    required this.child,
    required this.uid,
    required this.isSender,
    this.isFirstMessageInGroupedMessages = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = ExtraTheme.of(context).messageBackgroundColor(uid);

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

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(
            top: isFirstMessageInGroupedMessages && isSender ? 16 : 0,
            bottom: 6,
          ),
          child: Material(
            clipBehavior:
                settings.showMessageDetails.value ? Clip.hardEdge : Clip.none,
            borderRadius:
                settings.showMessageDetails.value ? border : BorderRadius.zero,
            elevation: settings.showMessageDetails.value ? 1 : 0,
            color: color,
            child: child,
          ),
        ),
        if (settings.showMessageDetails.value &&
            isFirstMessageInGroupedMessages)
          Positioned(
            left: isSender ? null : 10 - width,
            right: !isSender ? null : 10 - width,
            top: isSender ? 16 : 0,
            child: !isSender
                ? CustomPaint(
                    size: const Size(width, height),
                    foregroundPainter: OPainter(color),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: CustomPaint(
                      size: const Size(width, height),
                      foregroundPainter: OPainter(color),
                    ),
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

    path
      ..moveTo(x, 0)
      ..moveTo(0, 0)
      ..arcToPoint(
        Offset(x, y),
        radius: Radius.circular(y * 2),
      )
      ..lineTo(x, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
