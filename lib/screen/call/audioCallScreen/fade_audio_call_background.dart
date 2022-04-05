import 'package:flutter/material.dart';

class FadeAudioCallBackground extends StatefulWidget {
  final ImageProvider image;

  const FadeAudioCallBackground({Key? key, required this.image})
      : super(key: key);

  @override
  State<FadeAudioCallBackground> createState() =>
      _FadeAudioCallBackgroundState();
}

class _FadeAudioCallBackgroundState extends State<FadeAudioCallBackground> {
  List<double> gradientRadius = [
    0.4,
    0.6,
    0.9,
  ];
  List<Alignment> alignmentList = [
    Alignment.topRight,
    Alignment.topCenter,
    Alignment.topLeft,
  ];
  double radius = 0.0;
  Alignment center = Alignment.topCenter;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(seconds: 5),
      onEnd: () {
        setState(() {
          index = index + 1;
          radius = gradientRadius[index % gradientRadius.length];
          center = alignmentList[index % alignmentList.length];
        });
      },
      decoration: BoxDecoration(
        color: Color.alphaBlend(Colors.black54, theme.primaryColor),
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.dstATop,
          ),
          image: widget.image,
        ),
        gradient: RadialGradient(
          radius: radius,
          center: center,
          colors: [
            Color.alphaBlend(theme.primaryColor.withAlpha(150), Colors.white),
            Color.alphaBlend(Colors.black54, theme.primaryColor.withAlpha(200)),
          ],
        ),
      ),
    );
  }
}
