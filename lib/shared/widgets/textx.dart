import 'package:deliver/shared/methods/is_persian.dart';
import 'package:flutter/material.dart';

class TextX extends Text {
  TextX(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaleFactor,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  }) : super(textDirection: data.textDirection());
}
