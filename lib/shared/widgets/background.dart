import 'package:flutter/material.dart';
import 'package:we/shared/methods/colors.dart';

class Background extends StatelessWidget {
  const Background({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Color(0xFF94c697),
        width: double.infinity,
        child: Stack(
          children: [
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    Color(0xFFccdcb7),
                    Color(0x00ccdcb7),
                  ],
                  center: Alignment(0.9, 1),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFccdcb7),
                        Color(0x00ccdcb7),
                      ],
                      center: Alignment(0.3, 1),
                    ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                  colors: [
                    Color(0xFFbbd494),
                    Color(0x00bbd494),
                  ],
                  center: Alignment(-0.2, -.8),
                ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFbbd494),
                        Color(0x00bbd494),
                      ],
                      center: Alignment(-0.9, -1),
                    ))),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF75ba94),
                        Color(0x0075ba94),
                      ],
                      center: Alignment(-.8, 1),
                    ))),
            Container(
              width: double.infinity,
              child: Image(
                  image: AssetImage("assets/backgrounds/pattern-24.png"),
                  fit: BoxFit.scaleDown,
                  color: Color(0xFF7ab07e).withOpacity(0.7),
                  repeat: ImageRepeat.repeat),
            ),
          ],
        ),
      ),
    );
  }
}
