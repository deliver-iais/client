import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

abstract class Feature {}

class UrlFeature extends Feature {
  final String url;

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

class IdFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is IdFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class BotCommandFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is BotCommandFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class EmojiFeature extends Feature {
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is BoldFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class ItalicFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is ItalicFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class UnderlineFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is UnderlineFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class StrikethroughFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is StrikethroughFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class SpoilerFeature extends Feature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is SpoilerFeature);

  @override
  int get hashCode => Object.hash(runtimeType, "");
}

class Block {
  final String text;
  final Set<Feature> features;

  const Block({required this.text, required this.features});
}

class Partition {
  final int start;
  final int end;
  final Set<Feature> features;
  final String? replacedText;

  Partition(this.start, this.end, this.features, {this.replacedText});
}

typedef Detector = List<Partition> Function(Block);

typedef Transformer<T> = T Function(Block);

typedef ThemeBasedTransformer<T> = Transformer<T> Function(ThemeData);

List<Block> partitioner(Block block, Detector detector) {
  final partitions = detector(block);

  final text = block.text;

  final blocks = <Block>[];

  var start = 0;

  for (final p in partitions) {
    if (text.substring(start, p.start).isNotEmpty) {
      blocks.add(
        Block(text: text.substring(start, p.start), features: block.features),
      );
    }

    if (text.substring(p.start, p.end).isNotEmpty) {
      blocks.add(
        Block(
          text: p.replacedText ?? text.substring(p.start, p.end),
          features: {...block.features, ...p.features},
        ),
      );
    }

    start = p.end;
  }

  if (text.substring(start).isNotEmpty) {
    blocks.add(Block(text: text.substring(start), features: block.features));
  }

  return blocks;
}

List<Block> onePathDetection(List<Block> blocks, Detector detector) =>
    blocks.map((b) => partitioner(b, detector)).expand((e) => e).toList();

List<T> onePathTransform<T>(
  List<Block> blocks,
  Transformer<T> transformer,
) =>
    blocks.map(transformer).toList();

List<T> onePath<T>(
  List<Block> initialBlocks,
  List<Detector> detectors,
  Transformer<T> transformer,
) =>
    onePathTransform(
      detectors.fold<List<Block>>(initialBlocks, onePathDetection),
      transformer,
    );
