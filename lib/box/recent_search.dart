import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'recent_search.g.dart';

@HiveType(typeId: RECENT_SEARCH_TRACK_ID)
class RecentSearch {
  @HiveField(0)
  String roomId;

  @HiveField(1)
  int time;

  RecentSearch({required this.roomId, required this.time});

  RecentSearch copyWith({
    String? roomId,
    int? time,
  }) =>
      RecentSearch(
        roomId: roomId ?? this.roomId,
        time: time ?? this.time,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is RecentSearch &&
          const DeepCollectionEquality().equals(other.roomId, roomId) &&
          const DeepCollectionEquality().equals(other.time, time));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomId),
        const DeepCollectionEquality().hash(time),
      );
}
