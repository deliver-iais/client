import 'package:we/theme/extra_theme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final bool isSent;

  const MessageWrapper({Key key, this.child, this.isSent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const radius = const Radius.circular(12);
    const border = const BorderRadius.all(radius);
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: border, boxShadow: [
          BoxShadow(
              color: Colors.black38, blurRadius: 0.5, offset: Offset(0, 0.5))
        ]),
        child: Stack(
          children: [
            Positioned(
              left: isSent ? null : 0,
              right: !isSent ? null : 0,
              top: 0,
              child: Container(
                  // color: Colors.white,
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    foregroundPainter: OPainter(
                        isSent
                            ? ExtraTheme.of(context).sentMessageBox
                            : ExtraTheme.of(context).receivedMessageBox,
                        isSent),
                  )),
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
  final bool isSent;

  OPainter(this.color, this.isSent);

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    //draw arc
    canvas.drawArc(
        Offset(isSent ? 5 : -12, 3) & Size(size.width * 1.3, size.height * 1.2),
        isSent ? -3 : -2, //radians
        isSent ? 2 : 2, //radians
        true,
        paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
