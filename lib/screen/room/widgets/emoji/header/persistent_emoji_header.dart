
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';



class PersistentEmojiHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;
  final double height;

  PersistentEmojiHeader({
    required this.widget,
    this.height = PERSISTENT_EMOJI_HEADER_HEIGHT,
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
