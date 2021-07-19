import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry largePagePadding;
  final BorderRadius borderRadius;
  final BorderRadius largePageBorderRadius;

  Box({
    this.child,
    this.padding,
    this.largePagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius,
    this.largePageBorderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? (isLarge(context) ? largePagePadding : EdgeInsets.zero),
      child: ClipRRect(
        borderRadius: borderRadius ??
            (isLarge(context) ? largePageBorderRadius : BorderRadius.zero),
        child: Container(
          color: ExtraTheme.of(context).boxOuterBackground,
          child: child,
        ),
      ),
    );
  }
}

class BoxList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry largePagePadding;
  final BorderRadius borderRadius;
  final BorderRadius largePageBorderRadius;

  BoxList({
    this.children,
    this.padding,
    this.largePagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius,
    this.largePageBorderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    return Box(
        padding: padding,
        largePagePadding: largePagePadding,
        borderRadius: borderRadius,
        largePageBorderRadius: largePageBorderRadius,
        child: Column(children: children));
  }
}
