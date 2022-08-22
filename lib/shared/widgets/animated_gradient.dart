import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedGradient extends StatefulWidget {
  final bool isAlignmentGradiant;
  final bool isConnected;

  const AnimatedGradient({
    super.key,
    required this.isConnected,
    this.isAlignmentGradiant = false,
  });

  @override
  AnimatedGradientState createState() => AnimatedGradientState();
}

class AnimatedGradientState extends State<AnimatedGradient> {
  List<Color> colorList = [
    Colors.teal,
    Colors.cyan,
    Colors.cyanAccent,
    Colors.lightBlue,
  ];

  List<Color> colorListConnected = [
    const Color.fromARGB(255, 75, 105, 100),
    const Color.fromARGB(255, 45, 83, 110),
    const Color.fromARGB(255, 49, 89, 107),
  ];

  int index = 0;
  int indexConnected = 0;
  Color bottomColor = Colors.teal;
  Color midColor = Colors.cyan;
  Color topColor = Colors.greenAccent;
  Timer? gradiantTimer;

  @override
  void dispose() {
    super.dispose();
    gradiantTimer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    gradiantTimer = Timer(const Duration(milliseconds: 10), () {
      setState(() {
        bottomColor = const Color.fromARGB(255, 49, 89, 107);
      });
    });
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            onEnd: () {
              if (widget.isConnected) {
                setState(() {
                  indexConnected = indexConnected + 1;
                  // animate the color
                  bottomColor = colorListConnected[indexConnected % colorListConnected.length];
                  midColor = colorListConnected[(indexConnected + 1) % colorListConnected.length];
                  topColor = colorListConnected[(indexConnected + 2) % colorListConnected.length];
                });
              } else {
                setState(() {
                  index = index + 1;
                  // animate the color
                  bottomColor = colorList[index % colorList.length];
                  midColor = colorList[(index + 1) % colorList.length];
                  topColor = colorList[(index + 2) % colorList.length];
                });
              }
            },
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [bottomColor, midColor, topColor],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
