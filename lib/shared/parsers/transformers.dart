import 'package:collection/collection.dart';
import 'package:deliver/shared/loaders/spoiler_loader.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Transformers
String simpleTransformer(Block block) => block.text;

typedef OnUsernameClick = void Function(String);
typedef OnBotCommandClick = void Function(String);
typedef OnUrlClick = void Function(String);

Transformer<InlineSpan> inlineSpanTransformer({
  required Color defaultColor,
  required Color linkColor,
  OnUsernameClick? onIdClick,
  OnBotCommandClick? onBotCommandClick,
  OnUrlClick? onUrlClick,
}) {
  return (b) {
    final url = b.features.whereType<UrlFeature>().firstOrNull;
    final id = b.features.whereType<IdFeature>().firstOrNull;
    final botCommand = b.features.whereType<BotCommandFeature>().firstOrNull;
    final emoji = b.features.whereType<EmojiFeature>().firstOrNull;
    final searchTerm = b.features.whereType<SearchTermFeature>().firstOrNull;
    final spoiler = b.features.whereType<SpoilerFeature>().firstOrNull;
    final bold = b.features.whereType<BoldFeature>().firstOrNull;
    final underline = b.features.whereType<UnderlineFeature>().firstOrNull;
    final italic = b.features.whereType<ItalicFeature>().firstOrNull;
    final strikethrough =
        b.features.whereType<StrikethroughFeature>().firstOrNull;

    final text = b.text;
    var textStyle = TextStyle();
    final textDecorations = <TextDecoration>[];

    GestureRecognizer? gestureRecognizer;

    if (spoiler != null) {
      return WidgetSpan(
        baseline: TextBaseline.ideographic,
        alignment: PlaceholderAlignment.middle,
        child: SpoilerLoader(
          b.text,
          foreground: defaultColor,
        ),
      );
    }

    if (url != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () => onUrlClick?.call(url.url);
    } else if (id != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () => onIdClick?.call(text);
    } else if (botCommand != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      gestureRecognizer = TapGestureRecognizer()
        ..onTap = () => onBotCommandClick?.call(text);
    }

    if (emoji != null) {
      textStyle = GoogleFonts.notoEmoji(textStyle: textStyle);
    }

    if (searchTerm != null) {
      textStyle = textStyle.copyWith(backgroundColor: Colors.yellow.shade500);
    }

    if (bold != null) {
      textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    }

    if (italic != null) {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
    }

    if (underline != null) {
      textDecorations.add(TextDecoration.underline);
    }

    if (strikethrough != null) {
      textDecorations.add(TextDecoration.lineThrough);
    }

    if (textDecorations.isNotEmpty) {
      textStyle = textStyle.copyWith(
        decoration: TextDecoration.combine(textDecorations),
      );
    }

    return TextSpan(
      text: text,
      recognizer: gestureRecognizer,
      style: textStyle,
    );
  };
}
