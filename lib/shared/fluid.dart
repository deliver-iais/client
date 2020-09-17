import 'package:deliver_flutter/theme/sizing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FluidWidget extends StatelessWidget {
  final Widget child;

  FluidWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return isDesktop()
        ? Container(
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromARGB(255, 0, 105, 247),
                Color.fromARGB(255, 25, 172, 247)
              ],
            )),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  constraints: BoxConstraints(
                      maxWidth: FLUID_MAX_WIDTH, maxHeight: FLUID_MAX_HEIGHT),
                  child: child,
                ),
              ),
            ),
          )
        : child;
  }
}
