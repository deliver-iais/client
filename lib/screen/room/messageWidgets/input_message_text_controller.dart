import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:flutter/material.dart';

class InputMessageTextController extends TextEditingController {
  bool isMarkDownEnable = false;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = isMarkDownEnable
        ? onePath(
            [Block(text: text, features: {})],
            inputTextDetectors(),
            inlineSpanTransformer(
              defaultColor: Theme.of(context).colorScheme.onSurface,
              linkColor: Theme.of(context).colorScheme.primary,
              justHighlightSpoilers: true,
            ),
          )
        : [TextSpan(text: text)];

    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
