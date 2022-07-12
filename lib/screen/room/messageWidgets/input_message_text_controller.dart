import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:flutter/widgets.dart';

class InputMessageTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final spans = onePath(
      [Block(text: text, features: {})],
      [emojiDetector()],
      emojiTransformer(),
    );

    return TextSpan(
      style: style,
      children: spans,
    );
  }
}
