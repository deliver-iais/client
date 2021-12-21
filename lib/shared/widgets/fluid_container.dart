import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidContainerWidget extends StatelessWidget {
  final Widget child;

  const FluidContainerWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Background(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(0),
            constraints:
                const BoxConstraints(maxWidth: FLUID_CONTAINER_MAX_WIDTH),
            child: child,
          ),
        ),
      ],
    );
  }
}
