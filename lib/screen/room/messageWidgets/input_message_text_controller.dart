import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:flutter/widgets.dart';

class InputMessageTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    List<Block> blocks = [Block(text: text)];
    List<Parser> parsers = [
      EmojiParser(fontSize: 16),
      // BoldTextParser(),
      // ItalicTextParser()
    ];
    for (final p in parsers) {
      blocks = p.parse(blocks, context);
    }

    return TextSpan(
        style: style,
        children: blocks
            .where((b) => b.text.isNotEmpty)
            .map((e) => TextSpan(text: e.text, style: e.style))
            .toList());
  }
}
