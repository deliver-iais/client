import 'package:flutter/material.dart';
import 'package:we/shared/methods/colors.dart';

class Background extends StatelessWidget {
  const Background({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFF94c697)
        : Color(0xFF00101A);

    final foregroundColor = Theme.of(context).brightness == Brightness.light
        ? Color(0xFF7ab07e).withOpacity(0.7)
        : Color(0xFF00233B).withOpacity(0.8);

    final yellow = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFbbd494)
        : Color(0xFF002031);

    final yellowTransparent = Theme.of(context).brightness == Brightness.light
        ? Color(0x00bbd494)
        : Color(0x00002031);

    final white = Theme.of(context).brightness == Brightness.light
        ? Color(0xFFccdcb7)
        : yellow;

    final whiteTransparent = Theme.of(context).brightness == Brightness.light
        ? Color(0x00ccdcb7)
        : yellowTransparent;

    final dark = Theme.of(context).brightness == Brightness.light
        ? Color(0xFF75ba94)
        : Color(0xFF000C11);

    final darkTransparent = Theme.of(context).brightness == Brightness.light
        ? Color(0x0075ba94)
        : Color(0x00000C11);

    return Center(
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    white,
                    whiteTransparent,
                  ],
                  center: Alignment(0.9, 1),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    white,
                    whiteTransparent,
                  ],
                  center: Alignment(0.3, 1),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    yellow,
                    yellowTransparent,
                  ],
                  center: Alignment(-0.2, -.8),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    yellow,
                    yellowTransparent,
                  ],
                  center: Alignment(-0.9, -1),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    dark,
                    darkTransparent,
                  ],
                  center: Alignment(-.8, 1),
                ))),
            Container(
              width: double.infinity,
              child: Image(
                  image: AssetImage("assets/backgrounds/pattern-24.png"),
                  fit: BoxFit.scaleDown,
                  color: foregroundColor,
                  repeat: ImageRepeat.repeat),
            ),
          ],
        ),
      ),
    );
  }
}
