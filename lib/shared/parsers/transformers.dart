import 'package:collection/collection.dart';
import 'package:deliver/fonts/fonts.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/loaders/spoiler_loader.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';

// Transformers
String simpleTransformer(Block block) => block.text;

typedef OnUsernameClick = void Function(String);
typedef OnBotCommandClick = void Function(String);
typedef OnUrlClick = void Function(String);

Transformer<InlineSpan> inlineSpanTransformer({
  required Color defaultColor,
  required Color linkColor,
  required Color codeBackgroundColor,
  required Color codeForegroundColor,
  required ColorScheme colorScheme,
  OnUsernameClick? onIdClick,
  OnBotCommandClick? onBotCommandClick,
  OnUrlClick? onUrlClick,
  bool justHighlightSpoilers = false,
  int? messageId,
}) {
  return (b) {
    final roomRepo = GetIt.I.get<RoomRepo>();
    final accountRepo = GetIt.I.get<AccountRepo>();
    final noFormattingRegion =
        b.features.whereType<NoFormattingRegion>().firstOrNull;
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
    final grayOut = b.features.whereType<GrayOutFeature>().firstOrNull;

    final text = synthesizeToOriginalWord(b.text);
    var textStyle = const TextStyle();
    final textDecorations = <TextDecoration>[];

    GestureRecognizer? gestureRecognizer;

    if (noFormattingRegion != null) {
      textStyle = codeFont().copyWith(
        color: colorScheme.onTertiaryContainer,
        backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.7),
      );
      if (onUrlClick != null) {
        gestureRecognizer = TapGestureRecognizer()
          ..onTap = () => saveToClipboard(noFormattingRegion.value);
      }
    }

    if (spoiler != null) {
      if (!justHighlightSpoilers) {
        return WidgetSpan(
          baseline: TextBaseline.ideographic,
          alignment: PlaceholderAlignment.middle,
          child: SpoilerLoader(b.text),
        );
      } else {
        textStyle = textStyle.copyWith(
          backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.5),
        );
      }
    }

    final linkColor = colorScheme.primary;

    if (url != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      if (onUrlClick != null) {
        gestureRecognizer = TapGestureRecognizer()
          ..onTap = () => onUrlClick.call(url.url);
      }
    } else if (id != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      if (onIdClick != null) {
        gestureRecognizer = TapGestureRecognizer()
          ..onTap = () => onIdClick.call(text);
      }
    } else if (botCommand != null) {
      textStyle = textStyle.copyWith(color: linkColor);
      if (onBotCommandClick != null) {
        gestureRecognizer = TapGestureRecognizer()
          ..onTap = () => onBotCommandClick.call(text);
      }
    }

    if (emoji != null) {
      textStyle = emojiFont(textStyle: textStyle);
    }

    if (searchTerm != null) {
      textStyle = textStyle.copyWith(backgroundColor: Colors.yellow.shade500);
    }
    if (grayOut != null) {
      textStyle = textStyle.copyWith(color: Colors.grey);
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


    if (messageId!= null && id != null && text=="@${accountRepo.getAccount()?.username}") {
      return WidgetSpan(
        child: StreamBuilder<int?>(
          stream: roomRepo.mentionAnimationId,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == messageId) {
              return IntrinsicHeight(
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: mainBorder,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.tertiaryContainer
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.tertiaryContainer.withOpacity(0.6)
                              ],
                            ),
                            borderRadius: mainBorder,
                          ),
                        )
                            .animate()
                            .scaleXY(
                              begin: 12,
                              end: 1,
                              duration: const Duration(milliseconds: 1500),
                              delay: const Duration(milliseconds: 1200),
                              curve: Curves.easeInOutQuad,
                            )
                            .shimmer(
                              color: colorScheme.surface,
                              delay: const Duration(milliseconds: 2000),
                            ),
                        Text.rich(
                          _buildTextSpan(text, gestureRecognizer, textStyle),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Text.rich(
                _buildTextSpan(text, gestureRecognizer, textStyle),
              );
            }
          },
        ),
        // recognizer: gestureRecognizer,
      );
    } else {
      return _buildTextSpan(text, gestureRecognizer, textStyle);
    }
  };
}

TextSpan _buildTextSpan(
  String text,
  GestureRecognizer? gestureRecognizer,
  TextStyle textStyle,
) =>
    TextSpan(text: text, recognizer: gestureRecognizer, style: textStyle);

Transformer<InlineSpan> simpleInlineSpanTransformer({
  required Color defaultColor,
  required Color linkColor,
}) {
  return (b) {
    final emoji = b.features.whereType<EmojiFeature>().firstOrNull;
    final searchTerm = b.features.whereType<SearchTermFeature>().firstOrNull;
    final spoiler = b.features.whereType<SpoilerFeature>().firstOrNull;
    final bold = b.features.whereType<BoldFeature>().firstOrNull;
    final underline = b.features.whereType<UnderlineFeature>().firstOrNull;
    final italic = b.features.whereType<ItalicFeature>().firstOrNull;
    final strikethrough =
        b.features.whereType<StrikethroughFeature>().firstOrNull;

    final text = synthesizeToOriginalWord(b.text);
    var textStyle = const TextStyle();
    final textDecorations = <TextDecoration>[];

    GestureRecognizer? gestureRecognizer;

    if (spoiler != null) {
      return WidgetSpan(
        baseline: TextBaseline.ideographic,
        alignment: PlaceholderAlignment.middle,
        child: SpoilerLoader(
          b.text,
          disableSpoilerReveal: true,
          foreground: defaultColor,
        ),
      );
    }

    if (emoji != null) {
      textStyle = emojiFont(textStyle: textStyle);
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

Transformer<TextSpan> emojiTransformer() {
  return (b) {
    final emoji = b.features.whereType<EmojiFeature>().firstOrNull;

    final text = synthesizeToOriginalWord(b.text);
    var textStyle = const TextStyle();

    if (emoji != null) {
      textStyle = emojiFont(textStyle: textStyle);
    }

    return TextSpan(
      text: text,
      style: textStyle,
    );
  };
}

Transformer<String> textTransformer() {
  return (b) {
    final spoiler = b.features.whereType<SpoilerFeature>().firstOrNull;

    if (spoiler != null) {
      return "▩" * b.text.length;
    } else {
      return synthesizeToOriginalWord(b.text);
    }
  };
}
