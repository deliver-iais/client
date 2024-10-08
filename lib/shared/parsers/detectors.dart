import 'package:collection/collection.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';

List<Detector> detectorsWithSearchTermDetector({String searchTerm = ""}) => [
      noFormattingRegionDetector(),
      inlineUrlDetector(),
      urlDetector(),
      idDetector(),
      if (!isMacOSDevice && settings.parseAndShowGoogleEmojis.value)
        emojiDetector(),
      botCommandDetector(),
      boldDetector(),
      underlineDetector(),
      italicDetector(),
      strikethroughDetector(),
      spoilerDetector(),
      if (searchTerm.isNotEmpty) searchTermDetector(searchTerm),
    ];

List<Detector> inputTextDetectors() => grayOutDetector([
      noFormattingRegionDetector(),
      inlineUrlDetector(replaceWithContactName: false),
      urlDetector(),
      idDetector(),
      if (!isMacOSDevice && settings.parseAndShowGoogleEmojis.value)
        emojiDetector(),
      botCommandDetector(),
      boldDetector(),
      underlineDetector(),
      italicDetector(),
      strikethroughDetector(),
      spoilerDetector(),
      ignoreCharacterDetector(),
    ]);

final List<Detector> detectors = [
  noFormattingRegionDetector(),
  urlDetector(),
  inlineUrlDetector(),
  idDetector(),
  emojiDetector(),
  botCommandDetector(),
  boldDetector(),
  underlineDetector(),
  italicDetector(),
  strikethroughDetector(),
  spoilerDetector(),
];

final justSpoilerDetectors = [spoilerDetector(), inlineUrlDetector()];

List<Detector> grayOutDetector(List<Detector> detectors) =>
    detectors.map((d) => (block) => _grayOutDetector(block, d)).toList();

List<Partition> _grayOutDetector(
  Block block,
  Detector detector,
) {
  final pList = detector(block);

  final text = block.text;

  final partitions = <Partition>[];

  for (final p in pList) {
    if (text.substring(p.start, p.end).isNotEmpty) {
      final actualText = text.substring(p.start, p.end);
      if (p.replacedText != null && p.replacedText!.isNotEmpty) {
        final match = p.replacedText!.allMatches(actualText).firstOrNull;

        if (match != null) {
          if (actualText.substring(0, match.start).isNotEmpty) {
            partitions.add(
              Partition(
                p.start,
                p.start + match.start,
                {GrayOutFeature()},
                lockToMoreParsing: true,
              ),
            );
          }
          if (actualText.substring(match.start, match.end).isNotEmpty) {
            partitions.add(
              Partition(
                p.start + match.start,
                p.start + match.end,
                p.features,
              ),
            );
          }
          if (actualText.substring(match.end, actualText.length).isNotEmpty) {
            partitions.add(
              Partition(
                p.start + match.end,
                p.end,
                {GrayOutFeature()},
                lockToMoreParsing: true,
              ),
            );
          }
        } else {
          partitions.add(p);
        }
      } else {
        partitions.add(p);
      }
    } else {
      partitions.add(p);
    }
  }

  return partitions;
}

Detector urlDetector() => simpleRegexDetectorWithGenerator(
      UrlFeature.urlRegex,
      (match) => {UrlFeature(match)},
      lockToMoreParsing: true,
    );

Detector noFormattingRegionDetector() => simpleRegexDetectorWithGenerator(
      NoFormattingRegion.regex,
      (match) => {
        NoFormattingRegion(
          match.substring(3, match.length - 3),
        )
      },
      replacer: (match) => match.substring(3, match.length - 3),
      lockToMoreParsing: true,
    );

Detector inlineUrlDetector({bool replaceWithContactName = true}) =>
    simpleRegexDetectorWithGenerator(
      UrlFeature.inlineUrlRegex,
      (match) => {
        UrlFeature(
          match.substring(match.indexOf("]") + 2, match.indexOf(")")),
        )
      },
      replacer: (match) {
        if (replaceWithContactName) {
          try {
            final url =
                match.substring(match.indexOf("(") + 1, match.indexOf(")"));
            if (UrlHandlerService.isApplicationUrl(url)) {
              final node = Uri.parse(url).queryParameters["id"];
              if (node != null) {
                final name = GetIt.I.get<RoomRepo>().getContactNameFromCache(
                      Uid()
                        ..node = node
                        ..category = Categories.USER,
                    );
                if (name != null) {
                  return "@$name";
                }
              }
            }
          } catch (_) {}
        }
        return match.substring(match.indexOf("[") + 1, match.indexOf("]"));
      },
    );

Detector idDetector() => idRegexDetector(IdFeature.regex, {IdFeature()});

Detector emojiDetector() => simpleRegexDetector(
      EmojiFeature.regex,
      {EmojiFeature()},
    );

Detector botCommandDetector() =>
    simpleRegexDetector(BotCommandFeature.regex, {BotCommandFeature()});

Detector searchTermDetector(String searchTerm) =>
    simpleRegexDetector(searchTerm, {SearchTermFeature()});

Detector ignoreCharacterDetector() => (block) {
      final text = block.text;

      var idx = 0;

      final partitions = <Partition>[];

      while (idx < text.length - 1) {
        final char = text[idx];
        final nextChar = text[idx + 1];
        final nextNextChar = (idx + 2 < text.length) ? text[idx + 2] : "";

        if (char == '\\') {
          if (nextChar == "*" ||
              nextChar == "~" ||
              nextChar == "_" ||
              (nextChar == "|" && nextNextChar == "|") ||
              (nextChar == "_" && nextNextChar == "_")) {
            partitions.add(Partition(idx, idx + 1, {GrayOutFeature()}));
          }
        }
        idx += 1;
        continue;
      }

      return partitions;
    };

Detector boldDetector() => simpleStyleDetectorTwoCharacter(
      BoldFeature.specialSingleChar,
      {BoldFeature()},
      replacer: (match) => match.substring(2, match.length - 2),
    );

Detector italicDetector() => simpleStyleDetectorTwoCharacter(
      ItalicFeature.specialSingleChar,
      {ItalicFeature()},
      replacer: (match) => match.substring(2, match.length - 2),
    );

Detector underlineDetector() => simpleStyleDetectorThreeCharacter(
      UnderlineFeature.specialSingleChar,
      {UnderlineFeature()},
      replacer: (match) => match.substring(3, match.length - 3),
    );

Detector strikethroughDetector() => simpleStyleDetector(
      StrikethroughFeature.specialSingleChar,
      {StrikethroughFeature()},
      replacer: (match) => match.substring(1, match.length - 1),
    );

Detector spoilerDetector() => simpleStyleDetectorTwoCharacter(
      SpoilerFeature.specialSingleChar,
      {SpoilerFeature()},
      replacer: (match) => match.substring(2, match.length - 2),
    );

Detector simpleRegexDetector(
  String source,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) => RegExp(source)
        .allMatches(synthesizeToOriginalWord(block.text))
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

Detector idRegexDetector(
  String source,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) => RegExp(source)
        .allMatches(synthesizeToOriginalWord(block.text))
        .where(
          (e) => (e.start == 0 ||
              block.text[e.start - 1] == " " ||
              block.text[e.start - 1] == "\n"),
        )
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
  bool lockToMoreParsing = false,
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
            lockToMoreParsing: lockToMoreParsing,
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
            } else if (start + 1 < idx && text[idx - 1] != specialChar) {
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
            } else if (start + 2 < idx && text[idx - 1] != specialChar) {
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
              idx += 1;
              start = null;
            }
          }

          idx += 1;
          continue;
        }
      }

      return partitions;
    };

Detector simpleStyleDetectorThreeCharacter(
  String specialChar,
  Set<Feature> features, {
  String Function(String)? replacer,
}) =>
    (block) {
      final text = block.text;

      var idx = 0;
      int? start;

      final partitions = <Partition>[];

      while (idx < text.length - 2) {
        final char = text[idx];
        final nextChar = text[idx + 1];
        final nextNextChar = text[idx + 2];

        if (char == '\\') {
          idx += 3;
          continue;
        } else {
          if (char == specialChar &&
              nextChar == specialChar &&
              nextNextChar == specialChar) {
            if (start == null) {
              start = idx;
            } else if (start + 3 < idx && text[idx - 1] != specialChar) {
              partitions.add(
                Partition(
                  start,
                  idx + 3,
                  features,
                  replacedText: replacer?.call(
                    block.text.substring(start, idx + 3),
                  ),
                ),
              );
              idx += 2;
              start = null;
            }
          }

          idx += 1;
          continue;
        }
      }

      return partitions;
    };
