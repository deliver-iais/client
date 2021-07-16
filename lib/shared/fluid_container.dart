import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidContainerWidget extends StatelessWidget {
  final Widget child;

  FluidContainerWidget({
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: ExtraTheme.of(context).boxBackground,
        constraints: BoxConstraints(maxWidth: FLUID_CONTAINER_MAX_WIDTH),
        child: child,
      ),
    );
  }
}
