import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'recent_rooms.g.dart';

@HiveType(typeId: RECENT_ROOMS_TRACK_ID)
class RecentRooms {
  @HiveField(0)
  String roomId;

  @HiveField(1)
  int count;

  RecentRooms({required this.roomId, required this.count});

  RecentRooms copyWith({
    String? roomId,
    int? count,
  }) =>
      RecentRooms(
        roomId: roomId ?? this.roomId,
        count: count ?? this.count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other.runtimeType == runtimeType &&
              other is RecentRooms &&
              const DeepCollectionEquality().equals(other.roomId, roomId) &&
              const DeepCollectionEquality().equals(other.count, count));

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(roomId),
    const DeepCollectionEquality().hash(count),
  );
}
