import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'emoji_skin_tone.g.dart';

@HiveType(typeId: EMOJI_SKIN_TONE_TRACK_ID)
class EmojiSkinTone {
  @HiveField(0)
  String char;

  @HiveField(1)
  int tone;

  EmojiSkinTone({required this.char, required this.tone});

  EmojiSkinTone copyWith({
    String? char,
    int? tone,
  }) =>
      EmojiSkinTone(
        char: char ?? this.char,
        tone: tone ?? this.tone,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is EmojiSkinTone &&
          const DeepCollectionEquality().equals(other.char, char) &&
          const DeepCollectionEquality().equals(other.tone, tone));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(char),
        const DeepCollectionEquality().hash(tone),
      );
}
