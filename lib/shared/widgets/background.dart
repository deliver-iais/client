import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final int id;

  const Background({Key? key, this.id = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF94c697)
        : const Color(0xFF00101A);

    final foregroundColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF7ab07e).withOpacity(0.7)
        : const Color(0xFF00233B).withOpacity(0.8);

    final yellow = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFbbd494)
        : const Color(0xFF002031);

    final yellowTransparent = Theme.of(context).brightness == Brightness.light
        ? const Color(0x00bbd494)
        : const Color(0x00002031);

    final white = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFccdcb7)
        : yellow;

    final whiteTransparent = Theme.of(context).brightness == Brightness.light
        ? const Color(0x00ccdcb7)
        : yellowTransparent;

    final dark = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF75ba94)
        : const Color(0xFF000C11);

    final darkTransparent = Theme.of(context).brightness == Brightness.light
        ? const Color(0x0075ba94)
        : const Color(0x00000C11);

    const List<Alignment> pp = [
      Alignment(-0.9, -1),
      Alignment(-0.3, -.8),
      Alignment(0, -.8),
      Alignment(0.3, -.8),
      Alignment(0.9, -1),
      Alignment(0.9, 0),
      Alignment(0.9, 1),
      Alignment(0.3, 1),
      Alignment(0, 1),
      Alignment(-.3, 1),
      Alignment(-.8, 1),
      Alignment(-.9, 0),
    ];

    final y = pp[(id) % 12];
    final y2 = pp[(id + 1) % 12];
    final w = pp[(id + 6) % 12];
    final w2 = pp[(id + 7) % 12];
    final b = pp[(id + 10) % 12];

    const duration = Duration(milliseconds: 500);
    const curve = Curves.easeOut;

    return Center(
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: isLarge(context)
                ? backgroundBorder
                : BorderRadius.zero,
          ),
          child: Stack(
            children: [
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
                    center: b,
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
                    center: y,
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
                    center: y2,
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
                    center: w,
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
                    center: w2,
                  ))),
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image(
                    image:
                        const AssetImage("assets/backgrounds/pattern-24.png"),
                    fit: BoxFit.scaleDown,
                    color: foregroundColor,
                    repeat: ImageRepeat.repeat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
