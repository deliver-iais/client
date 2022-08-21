import 'package:flutter/material.dart';

class CircularCheckMarkWidget extends StatelessWidget {
  final bool shouldShowCheckMark;

  const CircularCheckMarkWidget({
    Key? key,
    this.shouldShowCheckMark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return circleBorderWidget(
      context: context,
      child: shouldShowCheckMark
          ? const Icon(
              Icons.check,
              size: 15,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget circleBorderWidget({Widget? child, required BuildContext context}) {
    return Container(
      alignment: Alignment.center,
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        border: Border.all(width: 2, color: Colors.white),
        color: child != null ? Theme.of(context).primaryColor : null,
      ),
      child: child,
    );
  }
}
