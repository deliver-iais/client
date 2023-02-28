import 'dart:ui';

import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class BlurMenuCard extends StatelessWidget {
  final Widget child;

  const BlurMenuCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: messageBorder,
      type: MaterialType.button,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: messageBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
            clipBehavior: Clip.hardEdge,
            borderRadius: messageBorder,
            child: child,
          ),
        ),
      ),
    );
  }
}
