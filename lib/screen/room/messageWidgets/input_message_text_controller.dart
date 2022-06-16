import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:flutter/widgets.dart';

class InputMessageTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    var blocks = <Block>[Block(text: text)];
    final parsers = <Parser>[
      const EmojiParser(),
    ];
    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return TextSpan(
      style: style,
      children: blocks.where((b) => b.text.isNotEmpty).map((e) {
        if (e.type == BlockTypes.EMOJI) {
          return TextSpan(text: e.text, style: e.style?.copyWith(fontSize: 16));
        }
        return TextSpan(text: e.text, style: e.style);
      }).toList(),
    );
  }
}
