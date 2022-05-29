import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animation_wave_button.dart';
import 'package:flutter/material.dart';

class RecordAudioAnimation extends StatelessWidget {
  final double rightPadding;
  final double size;

  const RecordAudioAnimation({
    Key? key,
    required this.rightPadding,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: rightPadding + ((size - 1) * 3),
      child: AnimatedContainer(
        duration: ANIMATION_DURATION,
        width: 60,
        height: 50,
        color: Colors.transparent,
        child: (1 - size) == 0
            ? const Icon(Icons.mic)
            : const AnimationWaveButton(
                initialIsPlaying: true,
              ),
      ),
    );
  }
}
