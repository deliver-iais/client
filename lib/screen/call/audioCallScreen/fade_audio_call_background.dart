import 'package:flutter/material.dart';

class FadeAudioCallBackground extends StatelessWidget {
  final ImageProvider image;

  const FadeAudioCallBackground({Key? key, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff273745),
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.06),
            BlendMode.dstATop,
          ),
          image: image,
        ),
      ),
    );
  }
}
