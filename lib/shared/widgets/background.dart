import 'package:flutter/material.dart';

class Position {
  final Alignment x1;
  final Alignment x2;

  Position(this.x1, this.x2);
}

class Background extends StatelessWidget {
  final int id;

  const Background({Key key, this.id = 0}) : super(key: key);

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

    final List<Position> p = [
      Position(Alignment(-0.9, -1), Alignment(-0.2, -.8)),
      Position(Alignment(0.2, -.8), Alignment(0.9, -1)),
      Position(Alignment(0.3, 1), Alignment(0.9, 1)),
      Position(Alignment(-.8, 1), Alignment(-.3, 1)),
    ];

    final y = p[id % 4];
    final e = p[(id + 1) % 4];
    final w = p[(id + 2) % 4];
    final b = p[(id + 3) % 4];

    final duration = Duration(milliseconds: 500);
    final curve = Curves.easeOut;

    return Center(
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        child: Stack(
          children: [
            AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    yellow,
                    yellowTransparent,
                  ],
                  center: y.x1,
                ))),
            AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    yellow,
                    yellowTransparent,
                  ],
                  center: y.x2,
                ))),
            AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    white,
                    whiteTransparent,
                  ],
                  center: w.x1,
                ))),
            AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    white,
                    whiteTransparent,
                  ],
                  center: w.x2,
                ))),
            AnimatedContainer(
                duration: duration,
                curve: curve,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    dark,
                    darkTransparent,
                  ],
                  center: b.x1,
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
