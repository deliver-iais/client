import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animation_wave_button.dart';
import 'package:flutter/material.dart';

class RecordAudioAnimation extends StatelessWidget {
  final double rightPadding;
  final double size;

  const RecordAudioAnimation({
    super.key,
    required this.rightPadding,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: (1 - size) != 0 ? rightPadding + ((size - 1) * 3) : 0,
      child: AnimatedContainer(
        duration: ANIMATION_DURATION,
        width: 60,
        height: 50,
        color: Colors.transparent,
        child: (1 - size) != 0
            ? const AnimationWaveButton(
                initialIsPlaying: true,
              ) : const SizedBox.shrink(),
      ),
    );
  }
}
