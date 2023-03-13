import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:flutter/services.dart';

final _numberFormat = RegExp(r'^[\u06F0-\u06F90-9]*$');

final NumberInputFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) {
    if (_numberFormat.hasMatch(newValue.text)) {
      return newValue.copyWith(
        text: newValue.text.replaceFarsiNumber(),
      );
    } else {
      return oldValue;
    }
  },
);
