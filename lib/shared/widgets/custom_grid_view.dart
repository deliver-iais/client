import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class FlexibleFixedHeightGridView extends StatelessWidget {
  final int itemCount;
  final double height;
  final IndexedWidgetBuilder itemBuilder;

  const FlexibleFixedHeightGridView({
    super.key,
    this.height = 90,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        var gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisExtent: height,
        );
        if (isVeryLargeWidth(constraints.maxWidth)) {
          gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: height,
          );
        } else if (isLargeWidth(constraints.maxWidth)) {
          gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: height,
          );
        }

        return GridView.builder(
          gridDelegate: gridDelegate,
          itemBuilder: itemBuilder,
          itemCount: itemCount,
          shrinkWrap: true,
        );
      },
    );
  }
}
