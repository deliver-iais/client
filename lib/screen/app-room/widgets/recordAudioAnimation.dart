import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordAudioAnimation extends StatelessWidget {
  final double righPadding;
  final double size;

  RecordAudioAnimation({this.righPadding, this.size});

  var ANIMATION_DURATION = const Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: ANIMATION_DURATION,
      bottom: (1 - size) * 25,
      right: righPadding + ((1 - size) * 25),
      child: ClipOval(
        child: AnimatedContainer(
          duration: ANIMATION_DURATION,
          width: 50 * size,
          height: 50 * size,
          color: (1 - size) == 0 ? Colors.transparent : ExtraTheme.of(context).textDetails,
          child: Center(
            child: Icon(
              Icons.keyboard_voice,
              size: 14 * (size - 1) + IconTheme.of(context).size,
              color: ExtraTheme.of(context).textField,
            ),
          ),
        ),
      ),
    );
  }
}
