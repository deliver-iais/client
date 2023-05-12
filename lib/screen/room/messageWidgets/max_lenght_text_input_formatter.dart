import 'dart:math';

import 'package:flutter/services.dart';

class MaxLinesTextInputFormatter extends TextInputFormatter {
  MaxLinesTextInputFormatter(this._maxLines)
      : assert(_maxLines == -1 || _maxLines > 0);

  final int _maxLines;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    if (_maxLines > 0) {
      final regEx = RegExp("^.*((\n?.*){0,${_maxLines - 1}})");
      final newString = regEx.stringMatch(newValue.text) ?? "";
      final maxLength = newString.length;
      if (newValue.text.runes.length > maxLength) {
        final newSelection = newValue.selection.copyWith(
          baseOffset: min(newValue.selection.start, maxLength),
          extentOffset: min(newValue.selection.end, maxLength),
        );
        final iterator = RuneIterator(newValue.text);
        if (iterator.moveNext()) {
          for (var count = 0; count < maxLength; ++count) {
            if (!iterator.moveNext()) {
              break;
            }
          }
        }
        final truncated = newValue.text.substring(0, iterator.rawIndex);
        return TextEditingValue(
          text: truncated,
          selection: newSelection,
        );
      }
      return newValue;
    }
    return newValue;
  }
}
