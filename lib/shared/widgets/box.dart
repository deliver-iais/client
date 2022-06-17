import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry largePageMargin;
  final BorderRadius? borderRadius;
  final BorderRadius largePageBorderRadius;

  const Box({
    super.key,
    this.child,
    this.margin,
    this.largePageMargin = const EdgeInsets.symmetric(horizontal: 28),
    this.borderRadius,
    this.largePageBorderRadius = mainBorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin ?? (isLarge(context) ? largePageMargin : EdgeInsets.zero),
      child: ClipRRect(
        borderRadius: borderRadius ??
            (isLarge(context) ? largePageBorderRadius : BorderRadius.zero),
        child: Container(
          color: theme.colorScheme.surface,
          child: child,
        ),
      ),
    );
  }
}

class BoxList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? largePagePadding;
  final BorderRadius? borderRadius;
  final BorderRadius largePageBorderRadius;

  const BoxList({
    super.key,
    required this.children,
    this.padding,
    this.largePagePadding = const EdgeInsets.symmetric(horizontal: 28),
    this.borderRadius,
    this.largePageBorderRadius = secondaryBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Box(
      margin: padding,
      largePageMargin: largePagePadding!,
      borderRadius: borderRadius,
      largePageBorderRadius: largePageBorderRadius,
      child: Column(children: children),
    );
  }
}
