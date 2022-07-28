import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';

class FluidContainerWidget extends StatelessWidget {
  final Widget child;
  final bool showStandardContainer;
  final Color? backGroundColor;

  const FluidContainerWidget({
    super.key,
    required this.child,
    this.showStandardContainer = false,
    this.backGroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget widget;
    if (showStandardContainer) {
      widget = Container(
        constraints: const BoxConstraints(maxWidth: FLUID_CONTAINER_MAX_WIDTH),
        margin: const EdgeInsets.all(24.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: mainBorder,
          color: backGroundColor,
          gradient: (backGroundColor == null)
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    elevation(
                      theme.colorScheme.surface,
                      theme.colorScheme.primary,
                      2,
                    )
                  ],
                )
              : null,
          boxShadow: LIGHT_BOX_SHADOWS,
        ),
        child: child,
      );
    } else {
      widget = Container(
        constraints: const BoxConstraints(maxWidth: FLUID_CONTAINER_MAX_WIDTH),
        child: child,
      );
    }

    return Center(child: widget);
  }
}
