import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TextLoader extends StatelessWidget {
  final Text text;

  final double width;

  const TextLoader(this.text, {super.key, this.width = 80});

  @override
  Widget build(BuildContext context) {
    if (text.data == null || text.data!.isEmpty) return buildLoader(context);

    return text;
  }

  Widget buildLoader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      child: Shimmer.fromColors(
        baseColor: Colors.black12,
        highlightColor: Colors.black45,
        child: Container(
          width: width,
          height: (text.style?.fontSize ?? 10) + 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
