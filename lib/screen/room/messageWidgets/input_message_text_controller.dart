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
    final spans = onePathTransform(
      onePathMultiDetection(
        [Block(text: text, features: {})],
        detectorsWithSearchTermDetector(),
       forceToDeleteReplaceFunctions: true,
      ),
      inlineSpanTransformer(
        defaultColor: Theme.of(context).colorScheme.onPrimaryContainer,
        linkColor: Theme.of(context).colorScheme.primary,
      ),
    );

    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
