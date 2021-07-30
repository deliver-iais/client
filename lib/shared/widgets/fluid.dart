import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidWidget extends StatelessWidget {
  final Widget child;
  final BoxDecoration boxDecoration;

  FluidWidget(
      {this.child,
      this.boxDecoration = const BoxDecoration(
          gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color.fromARGB(255, 0, 105, 247),
          Color.fromARGB(255, 25, 172, 247)
        ],
      ))});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          decoration: boxDecoration,
          child: Center(
            child: ClipRRect(
              borderRadius: isLargeWidth(constraints.maxWidth)
                  ? BorderRadius.all(Radius.circular(8))
                  : BorderRadius.zero,
              child: Container(
                color: Theme.of(context).backgroundColor,
                constraints: BoxConstraints(
                    maxWidth: isLargeWidth(constraints.maxWidth)
                        ? FLUID_MAX_WIDTH
                        : double.infinity,
                    maxHeight: isLargeWidth(constraints.maxWidth)
                        ? FLUID_MAX_HEIGHT
                        : double.infinity),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
