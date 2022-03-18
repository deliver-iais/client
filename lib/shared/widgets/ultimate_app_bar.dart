import 'dart:ui';

import 'package:flutter/material.dart';

class UltimateAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UltimateAppBar(
      {Key? key, required this.child, required this.preferredSize})
      : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: child,
      ),
    );
  }
}
