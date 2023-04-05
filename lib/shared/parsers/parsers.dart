import 'package:collection/collection.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:flutter/material.dart';

abstract class Feature {}

class UrlFeature extends Feature {
  final String url;
  static const urlRegex =
      r"(https?://(www\.)?)?[-a-zA-Z\d@:%._+~#=]{1,256}\.[a-zA-Z\d()]{1,6}\b([-a-zA-Z\d()@:%_+.~#?&/=]*)|(we://(.+))";
  static const inlineUrlRegex =
      r"\[(((?!]).)+)\]\(((https?://(www\.)?)?[-a-zA-Z\d@:%._+~#=]{1,256}\.[a-zA-Z\d()]{1,6}\b([-a-zA-Z\d()@:%_+.~#?&/=]*)|(we://(.+)))\)";

  UrlFeature(this.url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is UrlFeature);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(url),
      );
}

class NoFormattingRegion extends Feature {
  final String value;
  static const regex = r"```(.|\n)*```";

  NoFormattingRegion(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is NoFormattingRegion);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(value),
      );
}

class IdFeature extends Feature {
  static const regex = r"@[a-zA-Z](\w){4,19}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is IdFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class BotCommandFeature extends Feature {
  static const regex = r"/([a-zA-Z\d_-]){5,40}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is BotCommandFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class GrayOutFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is BotCommandFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class EmojiFeature extends Feature {
  static const regex =
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is EmojiFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class SearchTermFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is SearchTermFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class BoldFeature extends Feature {
  static const specialSingleChar = "*";
  static const specialChar = "**";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is BoldFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class ItalicFeature extends Feature {
  static const specialSingleChar = "_";
  static const specialChar = "__";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is ItalicFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class UnderlineFeature extends Feature {
  static const specialSingleChar = "_";
  static const specialChar = "___";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is UnderlineFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class StrikethroughFeature extends Feature {
  static const specialSingleChar = "~";
  static const specialChar = "~";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is StrikethroughFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class SpoilerFeature extends Feature {
  static const specialSingleChar = "|";
  static const specialChar = "||";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is SpoilerFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class Block {
  final String text;
  final bool lockToMoreParsing;
  final Set<Feature> features;

  const Block({
    required this.text,
    required this.features,
    this.lockToMoreParsing = false,
  });
}

class Partition {
  final int start;
  final int end;
  final Set<Feature> features;
  final String? replacedText;
  final bool lockToMoreParsing;

  Partition(
    this.start,
    this.end,
    this.features, {
    this.replacedText,
    this.lockToMoreParsing = false,
  });
}

typedef Detector = List<Partition> Function(Block);

typedef Transformer<T> = T Function(Block);

typedef ThemeBasedTransformer<T> = Transformer<T> Function(ThemeData);

List<Block> partitioner(Block block, Detector detector) {
  if (block.lockToMoreParsing) {
    return [block];
  }

  try {
    final partitions = detector(block);

    final text = block.text;

    final blocks = <Block>[];

    var start = 0;

    for (final p in partitions) {
      if (text.characters.getRange(start, p.start).isNotEmpty) {
        blocks.add(
          Block(
            text: text.characters.getRange(start, p.start).string,
            features: block.features,
          ),
        );
      }

      if (text.characters.getRange(p.start, p.end).isNotEmpty) {
        blocks.add(
          Block(
            text: p.replacedText ??
                text.characters.getRange(p.start, p.end).string,
            features: {...block.features, ...p.features},
            lockToMoreParsing: p.lockToMoreParsing,
          ),
        );
      }

      start = p.end;
    }

    if (text.characters.getRange(start).isNotEmpty) {
      blocks.add(
        Block(
          text: text.characters.getRange(start).string,
          features: block.features,
        ),
      );
    }

    return blocks;
  } catch (e) {
    return [block];
  }
}

List<Block> onePathDetection(
  List<Block> blocks,
  Detector detector,
) =>
    blocks.map((b) => partitioner(b, detector)).expand((e) => e).toList();

List<Block> onePathMultiDetection(
  List<Block> blocks,
  List<Detector> detectors,
) =>
    detectors.fold<List<Block>>(
      blocks,
      (previousValue, element) => onePathDetection(previousValue, element),
    );

List<T> onePathTransform<T>(
  List<Block> blocks,
  Transformer<T> transformer,
) =>
    blocks.map(transformer).toList();

bool isTextContainUrlFeature(String text) {
  return getLinkBlocksFromText(text).isNotEmpty;
}

Iterable<Block> getLinkBlocksFromText(String text) {
  final blocks = onePathDetection(
    [
      Block(text: text, features: {}),
    ],
    urlDetector(),
  );
  return blocks
      .where(
        (element) => element.features.whereType<UrlFeature>().isNotEmpty,
      )
      .toList();
}

List<T> onePath<T>(
  List<Block> initialBlocks,
  List<Detector> detectors,
  Transformer<T> transformer,
) =>
    onePathTransform(
      onePathMultiDetection(initialBlocks, detectors),
      transformer,
    );
