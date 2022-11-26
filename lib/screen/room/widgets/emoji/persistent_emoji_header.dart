import 'package:flutter/material.dart';
const double PersistentEmojiHeaderHeight = 52.0;
class PersistentEmojiHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;

  PersistentEmojiHeader({required this.widget});

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return SizedBox(
      width: double.infinity,
      height: PersistentEmojiHeaderHeight,
      child: Center(child: widget),
    );
  }

  @override
  double get maxExtent => PersistentEmojiHeaderHeight;

  @override
  double get minExtent => PersistentEmojiHeaderHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
