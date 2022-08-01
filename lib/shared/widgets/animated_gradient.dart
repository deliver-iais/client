import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedGradient extends StatefulWidget {
  final bool isAlignmentGradiant;

  const AnimatedGradient({
    super.key,
    this.isAlignmentGradiant = false,
  });

  @override
  AnimatedGradientState createState() => AnimatedGradientState();
}

class AnimatedGradientState extends State<AnimatedGradient> {
  List<Color> colorList = [
    Colors.teal,
    Colors.greenAccent,
    Colors.cyan,
    Colors.green,
    Colors.cyanAccent,
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topLeft,
    Alignment.topRight,
  ];

  int index = 0;
  Color bottomColor = Colors.cyan;
  Color topColor = Colors.greenAccent;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;
  Timer? gradiantTimer;

  @override
  void dispose(){
    super.dispose();
    gradiantTimer!.cancel();
  }


  @override
  Widget build(BuildContext context) {
    gradiantTimer = Timer(const Duration(milliseconds: 10), () {
      setState(() {
        bottomColor = Colors.teal;
      });
    });
    return Scaffold(
        body: Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          onEnd: () {
            setState(() {
              index = index + 1;
              // animate the color
              bottomColor = colorList[index % colorList.length];
              topColor = colorList[(index + 1) % colorList.length];

              //// animate the alignment
              // begin = alignmentList[index % alignmentList.length];
              // end = alignmentList[(index + 2) % alignmentList.length];
            });
          },
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [bottomColor, topColor],
            ),
          ),
        ),
        // Positioned.fill(
        //   child: IconButton(
        //     icon: Icon(Icons.play_arrow),
        //     onPressed: () {
        //       setState(() {
        //         bottomColor = Colors.blue;
        //       });
        //     },
        //   ),
        // )
      ],
    ));
  }
}
