import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'seen.g.dart';

@HiveType(typeId: SEEN_TRACK_ID)
class Seen {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  int messageId;

  @HiveField(2)
  int? hiddenMessageCount;

  Seen({required this.uid, required this.messageId, this.hiddenMessageCount});

  Seen copyWith({
    String? uid,
    int? messageId,
    int? hiddenMessageCount,
  }) =>
      Seen(
        uid: uid ?? this.uid,
        messageId: messageId ?? this.messageId,
        hiddenMessageCount: hiddenMessageCount ?? this.hiddenMessageCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Seen &&
          const DeepCollectionEquality().equals(other.uid, uid) &&
          const DeepCollectionEquality().equals(other.messageId, messageId) &&
          const DeepCollectionEquality()
              .equals(other.hiddenMessageCount, hiddenMessageCount));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(uid),
        const DeepCollectionEquality().hash(messageId),
        const DeepCollectionEquality().hash(hiddenMessageCount),
      );
}
