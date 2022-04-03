import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class FluidContainerWidget extends StatelessWidget {
  final Widget child;
  final bool showStandardContainer;

  const FluidContainerWidget({
    Key? key,
    required this.child,
    this.showStandardContainer = false,
  }) : super(key: key);

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
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              elevation(
                theme.colorScheme.surface,
                theme.colorScheme.primary,
                2,
              )
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
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
