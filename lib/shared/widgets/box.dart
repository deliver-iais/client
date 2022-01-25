import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry largePageMargin;
  final BorderRadius? borderRadius;
  final BorderRadius largePageBorderRadius;

  const Box({Key? key,
    this.child,
    this.margin,
    this.largePageMargin = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius,
    this.largePageBorderRadius = const BorderRadius.all(Radius.circular(24)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? (isLarge(context) ? largePageMargin : EdgeInsets.zero),
      child: ClipRRect(
        borderRadius: borderRadius ??
            (isLarge(context) ? largePageBorderRadius : BorderRadius.zero),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
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

  const BoxList({Key? key,
    required this.children,
    this.padding,
    this.largePagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.borderRadius,
    this.largePageBorderRadius = const BorderRadius.all(Radius.circular(24)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Box(
        margin: padding,
        largePageMargin: largePagePadding!,
        borderRadius: borderRadius,
        largePageBorderRadius: largePageBorderRadius,
        child: Column(children: children));
  }
}
