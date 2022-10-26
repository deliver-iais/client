import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TextLoader extends StatelessWidget {
  final Text text;

  final double width;
  final BorderRadius? borderRadius;

  const TextLoader(this.text, {super.key, this.width = 80, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    if (text.data == null || text.data!.isEmpty) return buildLoader(context);

    return text;
  }

  Widget buildLoader(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: theme.outline.withOpacity(0.15),
      highlightColor: theme.onSurface.withOpacity(0.23),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: theme.surface,
        ),
        width: width,
        height: (text.style?.fontSize ?? 10) + 2,
      ),
    );
  }
}
