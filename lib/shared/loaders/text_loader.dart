import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class TextLoader extends StatelessWidget {
  final Text text;

  final double width;

  const TextLoader(this.text, {Key? key, this.width = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text.data == null || text.data!.isEmpty) return buildLoader(context);

    return text;
  }


  Widget buildLoader(BuildContext context) {
    final theme = Theme.of(context);

    return MirrorAnimation<Color?>(
      tween: ColorTween(
        begin: Color.lerp(
          theme.colorScheme.onSurface,
          theme.colorScheme.surface,
          0.4,
        ),
        end: Color.lerp(
          theme.colorScheme.onSurface,
          theme.colorScheme.surface,
          0.8,
        ),
      ),
      curve: Curves.easeInOut,
      duration: ANIMATION_DURATION * 15,
      builder: (context, child, value) {
        return Container(
          width: width,
          height: text.style?.fontSize ?? 10,
          decoration: BoxDecoration(
            color: value,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        );
      },
    );
  }
}
