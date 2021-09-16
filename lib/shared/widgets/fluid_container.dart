import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidContainerWidget extends StatelessWidget {
  final Widget child;

  FluidContainerWidget({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ExtraTheme.of(context).boxOuterBackground,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(0),
          color: ExtraTheme.of(context).boxBackground,
          constraints: BoxConstraints(maxWidth: FLUID_CONTAINER_MAX_WIDTH),
          child: child,
        ),
      ),
    );
  }
}
