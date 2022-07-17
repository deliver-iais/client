import 'package:deliver/shared/parsers/parsers.dart';
import 'package:flutter/material.dart';

List<Detector> detectorsWithSearchTermDetector({String searchTerm = ""}) => [
      inlineUrlDetector(),
      urlDetector(),
      idDetector(),
      emojiDetector(),
      botCommandDetector(),
      boldDetector(),
      italicDetector(),
      underlineDetector(),
      strikethroughDetector(),
      spoilerDetector(),
      if (searchTerm.isNotEmpty) searchTermDetector(searchTerm),
    ];

final List<Detector> detectors = [
  urlDetector(),
  inlineUrlDetector(),
  idDetector(),
  emojiDetector(),
  botCommandDetector(),
  boldDetector(),
  italicDetector(),
  underlineDetector(),
  strikethroughDetector(),
  spoilerDetector(),
];

final justSpoilerDetectors = [
  spoilerDetector(),
];

Detector urlDetector() => simpleRegexDetectorWithGenerator(
      UrlFeature.urlRegex,
      (match) => {UrlFeature(match)},
    );

Detector inlineUrlDetector() => simpleRegexDetectorWithGenerator(
      UrlFeature.inlineUrlRegex,
      (match) => {
        UrlFeature(match.substring(match.indexOf("]") + 2, match.indexOf(")")))
      },
      replacer: (match) =>
          match.substring(match.indexOf("[") + 1, match.indexOf("]")),
    );

Detector idDetector() => simpleRegexDetector(IdFeature.regex, {IdFeature()});

Detector emojiDetector() => simpleRegexDetector(
      EmojiFeature.regex,
      {EmojiFeature()},
    );

Detector botCommandDetector() =>
    simpleRegexDetector(BotCommandFeature.regex, {BotCommandFeature()});

Detector searchTermDetector(String searchTerm) =>
    simpleRegexDetector(searchTerm, {SearchTermFeature()});

Detector boldDetector() => simpleStyleDetector(
      BoldFeature.specialChar,
      {BoldFeature()},
      replacer: (match) => match.substring(1, match.length - 1),
    );

Detector italicDetector() => simpleStyleDetectorTwoCharacter(
      "_",
      {ItalicFeature()},
      replacer: (match) => match.substring(2, match.length - 2),
    );

Detector underlineDetector() => simpleStyleDetector(
      UnderlineFeature.specialChar,
      {UnderlineFeature()},
      replacer: (match) => match.substring(1, match.length - 1),
    );

Detector strikethroughDetector() => simpleStyleDetector(
      StrikethroughFeature.specialChar,
      {StrikethroughFeature()},
      replacer: (match) => match.substring(1, match.length - 1),
    );

Detector spoilerDetector() => simpleStyleDetectorTwoCharacter(
      "|",
      {SpoilerFeature()},
      replacer: (match) => match.substring(2, match.length - 2),
    );

Detector simpleRegexDetector(
  String source,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) => RegExp(source)
        .allMatches(block.text)
        .map(
          (e) => Partition(
            e.start,
            e.end,
            features,
            replacedText: replacer?.call(
              block.text.substring(e.start, e.end),
            ),
          ),
        )
        .toList();

Detector simpleRegexDetectorWithGenerator(
  String source,
  Set<Feature> Function(String) generateFeatures, {
  String Function(String)? replacer,
}) =>
    (block) => RegExp(source)
        .allMatches(block.text)
        .map(
          (e) => Partition(
            e.start,
            e.end,
            generateFeatures(
              block.text.substring(e.start, e.end),
            ),
            replacedText: replacer?.call(
              block.text.substring(e.start, e.end),
            ),
          ),
        )
        .toList();

Detector simpleStyleDetector(
  String specialChar,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) {
      final text = block.text;

      var idx = 0;
      int? start;

      final partitions = <Partition>[];

      while (idx < text.length) {
        final char = text[idx];

        if (char == '\\') {
          idx += 2;
          continue;
        } else {
          if (char == specialChar) {
            if (start == null) {
              start = idx;
            } else if (start + 1 < idx) {
              partitions.add(
                Partition(
                  start,
                  idx + 1,
                  features,
                  replacedText: replacer?.call(
                    block.text.substring(start, idx + 1),
                  ),
                ),
              );
              start = null;
            }
          }

          idx += 1;
          continue;
        }
      }

      return partitions;
    };

String createFormattedText(
  String specialChar,
  TextEditingController textController,
) {
  return "${textController.text.substring(0, textController.selection.start)}"
      "$specialChar${textController.text.substring(textController.selection.start, textController.selection.end)}"
      "$specialChar${textController.text.substring(textController.selection.end, textController.text.length)}";
}

String createLink(String text, String link) {
  return "[$text]($link)";
}

Detector simpleStyleDetectorTwoCharacter(
  String specialChar,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) {
      final text = block.text;

      var idx = 0;
      int? start;

      final partitions = <Partition>[];

      while (idx < text.length - 1) {
        final char = text[idx];
        final nextChar = text[idx + 1];

        if (char == '\\') {
          idx += 2;
          continue;
        } else {
          if (char == specialChar && nextChar == specialChar) {
            if (start == null) {
              start = idx;
            } else if (start + 2 < idx) {
              partitions.add(
                Partition(
                  start,
                  idx + 2,
                  features,
                  replacedText: replacer?.call(
                    block.text.substring(start, idx + 2),
                  ),
                ),
              );
              start = null;
            }
          }

          idx += 2;
          continue;
        }
      }

      return partitions;
    };
