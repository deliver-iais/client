import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'recent_emoji.g.dart';

@HiveType(typeId: RECENT_EMOJI_TRACK_ID)
class RecentEmoji {
  @HiveField(0)
  String char;

  @HiveField(1)
  int count;

  RecentEmoji({required this.char, required this.count});

  RecentEmoji copyWith({
    String? char,
    int? count,
  }) =>
      RecentEmoji(
        char: char ?? this.char,
        count: count ?? this.count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is RecentEmoji &&
          const DeepCollectionEquality().equals(other.char, char) &&
          const DeepCollectionEquality().equals(other.count, count));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(char),
        const DeepCollectionEquality().hash(count),
      );
}
