import 'package:deliver/services/settings.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TextLoader extends StatelessWidget {
  final Text? text;

  final double width;
  final BorderRadius? borderRadius;

  const TextLoader({
    super.key,
    this.width = 80,
    this.borderRadius,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null ||
        text?.data == null ||
        text!.data!.isEmpty ||
        text?.data == "\u200B") {
      return buildLoader(context);
    }

    return text!;
  }

  Widget buildLoader(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: theme.outline.withOpacity(0.15),
      highlightColor: theme.onSurface.withOpacity(0.23),
      enabled: settings.showAnimations.value,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: theme.surface,
        ),
        width: width,
        height: (text?.style?.fontSize ?? 10) + 2,
      ),
    );
  }
}
