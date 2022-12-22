import 'dart:ui';

import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';

class BlurMenuCard extends StatelessWidget {
  final Widget child;

  const BlurMenuCard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: DEFAULT_BOX_SHADOWS,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            clipBehavior: Clip.hardEdge,
            elevation: 1.0,
            type: MaterialType.card,
            child: child,
          ),
        ),
      ),
    );
  }
}
