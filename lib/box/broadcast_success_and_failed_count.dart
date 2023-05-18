import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'broadcast_success_and_failed_count.g.dart';

@HiveType(typeId: BROADCAST_SUCCESS_AND_FAILED_COUNT_TRACK_ID)
class BroadcastSuccessAndFailedCount {
  @HiveField(0)
  int broadcastSuccessCount;

  @HiveField(1)
  int broadcastFailedCount;

  @HiveField(2)
  int broadcastMessageId;

  BroadcastSuccessAndFailedCount({
    required this.broadcastSuccessCount,
    required this.broadcastFailedCount,
    required this.broadcastMessageId,
  });

  BroadcastSuccessAndFailedCount copy(BroadcastSuccessAndFailedCount bc) =>
      BroadcastSuccessAndFailedCount(
        broadcastSuccessCount: bc.broadcastSuccessCount,
        broadcastFailedCount: bc.broadcastFailedCount,
        broadcastMessageId: bc.broadcastMessageId,
      );

  BroadcastSuccessAndFailedCount copyWith({
    int? broadcastSuccessCount,
    int? broadcastFailedCount,
    int? broadcastMessageId,
  }) =>
      BroadcastSuccessAndFailedCount(
        broadcastSuccessCount:
            broadcastSuccessCount ?? this.broadcastSuccessCount,
        broadcastFailedCount: broadcastFailedCount ?? this.broadcastFailedCount,
        broadcastMessageId: broadcastMessageId ?? this.broadcastMessageId,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BroadcastSuccessAndFailedCount &&
            const DeepCollectionEquality()
                .equals(other.broadcastSuccessCount, broadcastSuccessCount) &&
            const DeepCollectionEquality()
                .equals(other.broadcastMessageId, broadcastMessageId) &&
            const DeepCollectionEquality()
                .equals(other.broadcastFailedCount, broadcastFailedCount));
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(broadcastSuccessCount),
        const DeepCollectionEquality().hash(broadcastMessageId),
        const DeepCollectionEquality().hash(broadcastFailedCount),
      );
}
