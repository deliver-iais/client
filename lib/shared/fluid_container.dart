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
        margin: const EdgeInsets.all(MAIN_PADDING * 1.1),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS)),
          child: Container(
            color: ExtraTheme.of(context).boxBackground,
            padding: const EdgeInsets.all(MAIN_PADDING * 1.4),
            constraints: BoxConstraints(maxWidth: BREAKDOWN_SIZE),
            child: child,
          ),
        ),
      ),
    );
  }
}
