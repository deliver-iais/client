import 'dart:ui';

import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class BlurredPreferredSizedWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const BlurredPreferredSizedWidget({
    super.key,
    required this.child,
    this.preferredSize = const Size.fromHeight(APPBAR_HEIGHT),
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    if (!settings.showBlurredComponents.value) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: child,
      );
    }
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 8),
        child: child,
      ),
    );
  }
}
