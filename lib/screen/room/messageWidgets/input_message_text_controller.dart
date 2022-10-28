import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:flutter/material.dart';

class InputMessageTextController extends TextEditingController {


  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = onePath(
            [Block(text: text, features: {})],
            inputTextDetectors(),
            inlineSpanTransformer(
              defaultColor: Theme.of(context).colorScheme.onSurface,
              linkColor: Theme.of(context).colorScheme.primary,
              justHighlightSpoilers: true,
            ),
          );

    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
