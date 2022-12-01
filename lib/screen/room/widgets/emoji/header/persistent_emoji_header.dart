
import 'package:flutter/material.dart';

const double PersistentEmojiHeaderHeight = 42.0;

class PersistentEmojiHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final double height;

  PersistentEmojiHeader({
    required this.widget,
    this.height = PersistentEmojiHeaderHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Center(child: widget),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
