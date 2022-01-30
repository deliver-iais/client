import 'package:flutter/material.dart';

class RecordAudioAnimation extends StatelessWidget {
  final double rightPadding;
  final double size;
  final animationDuration = const Duration(milliseconds: 100);

  const RecordAudioAnimation(
      {Key? key, required this.rightPadding, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPositioned(
      duration: animationDuration,
      bottom: (1 - size) * 25,
      right: rightPadding + ((1 - size) * 25),
      child: ClipOval(
        child: AnimatedContainer(
          duration: animationDuration,
          width: 50 * size,
          height: 50 * size,
          color: (1 - size) == 0
              ? Colors.transparent
              :theme.primaryColor,
          child: Center(
            child: Icon(
              Icons.keyboard_voice,
              size: 14 * (size - 1) + IconTheme.of(context).size!,
            ),
          ),
        ),
      ),
    );
  }
}
