import 'dart:ui';

import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final double skew;
  final bool blurIsEnabled;
  final Color? color;
  final BorderRadius borderRadius;

  const BlurContainer({
    super.key,
    required this.child,
    this.width,
    this.color,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.skew = 1.0,
    this.blurIsEnabled = true,
    this.borderRadius = mainBorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!blurIsEnabled) {
      return Container(
        padding: padding,
        decoration: decoration,
        height: height,
        width: width,
        child: child,
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.hardEdge,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: -skew, sigmaY: skew),
        child: Container(
          padding: padding,
          margin: margin,
          decoration: decoration ??
              BoxDecoration(
                color: color ?? theme.dividerColor.withOpacity(0.15),
              ),
          child: child,
        ),
      ),
    );
  }
}
