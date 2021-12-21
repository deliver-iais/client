import 'dart:ui';

import 'package:flutter/material.dart';

class BlurContainer extends StatelessWidget {
  final Widget child;

  const BlurContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
            padding: const EdgeInsets.only(
                top: 5, left: 8.0, right: 8.0, bottom: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.15),
            ),
            child: child),
      ),
    );
  }
}
