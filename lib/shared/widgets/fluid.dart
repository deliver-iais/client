import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class FluidWidget extends StatelessWidget {
  final Widget child;
  final BoxDecoration boxDecoration;

  const FluidWidget({
    Key? key,
    required this.child,
    this.boxDecoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color.fromARGB(255, 0, 105, 247),
          Color.fromARGB(255, 25, 172, 247)
        ],
      ),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: boxDecoration,
          child: Center(
            child: ClipRRect(
              borderRadius: isLargeWidth(constraints.maxWidth)
                  ? mainBorder
                  : BorderRadius.zero,
              child: Container(
                color: theme.backgroundColor,
                constraints: BoxConstraints(
                  maxWidth: isLargeWidth(constraints.maxWidth)
                      ? FLUID_MAX_WIDTH
                      : double.infinity,
                  maxHeight: isLargeWidth(constraints.maxWidth)
                      ? FLUID_MAX_HEIGHT
                      : double.infinity,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
