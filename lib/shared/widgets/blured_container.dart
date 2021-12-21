import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Decoration? decoration;
  final double skew;
  final bool blurIsEnabled;

  const BlurContainer(
      {Key? key,
      required this.child,
      this.padding,
      this.decoration,
      this.skew = 1.0,
      this.blurIsEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!blurIsEnabled) {
      return Container(
          padding: padding,
          decoration: decoration,
          child: child);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: skew, sigmaY: skew),
        child: Container(
            padding: padding,
            decoration: decoration ??
                BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                ),
            child: child),
      ),
    );
  }
}
