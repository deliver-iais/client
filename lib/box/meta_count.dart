import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'meta_count.g.dart';

@HiveType(typeId: META_COUNT_TRACK_ID)
class MetaCount {
  // DbId
  @HiveField(0)
  String roomId;

  @HiveField(1)
  int mediasCount;

  @HiveField(2)
  int filesCount;

  @HiveField(3)
  int callsCount;

  @HiveField(4)
  int voicesCount;

  @HiveField(5)
  int musicsCount;

  @HiveField(6)
  int linkCount;

  @HiveField(7)
  int allMediaDeletedCount;

  @HiveField(8)
  int allFilesDeletedCount;

  @HiveField(9)
  int allMusicsDeletedCount;

  @HiveField(10)
  int allVoicesDeletedCount;

  @HiveField(11)
  int allLinksDeletedCount;

  @HiveField(12)
  int allCallDeletedCount;

  @HiveField(13)
  int lastUpdateTime;

  MetaCount({
    required this.roomId,
    required this.mediasCount,
    required this.callsCount,
    required this.filesCount,
    required this.voicesCount,
    required this.musicsCount,
    required this.linkCount,
    required this.allCallDeletedCount,
    required this.allFilesDeletedCount,
    required this.allLinksDeletedCount,
    required this.allMediaDeletedCount,
    required this.allMusicsDeletedCount,
    required this.allVoicesDeletedCount,
    required this.lastUpdateTime,
  });

  MetaCount copyWith({
    String? roomUid,
    int? mediasCount,
    int? filesCount,
    int? voicesCount,
    int? musicsCount,
    int? linkCount,
    int? callsCount,
    int? allCallDeletedCount,
    int? allFilesDeletedCount,
    int? allLinksDeletedCount,
    int? allMediaDeletedCount,
    int? allMusicsDeletedCount,
    int? allVoicesDeletedCount,
    required int lastUpdateTime,
  }) =>
      MetaCount(
        roomId: roomId,
        mediasCount: mediasCount ?? this.mediasCount,
        filesCount: filesCount ?? this.filesCount,
        callsCount: callsCount ?? this.callsCount,
        voicesCount: voicesCount ?? this.voicesCount,
        musicsCount: musicsCount ?? this.musicsCount,
        linkCount: linkCount ?? this.linkCount,
        allVoicesDeletedCount:
            allVoicesDeletedCount ?? this.allVoicesDeletedCount,
        allMusicsDeletedCount:
            allMusicsDeletedCount ?? this.allMusicsDeletedCount,
        allMediaDeletedCount: allMediaDeletedCount ?? this.allMediaDeletedCount,
        allLinksDeletedCount: allLinksDeletedCount ?? this.allLinksDeletedCount,
        allCallDeletedCount: allCallDeletedCount ?? this.allCallDeletedCount,
        allFilesDeletedCount: allFilesDeletedCount ?? this.allFilesDeletedCount,
        lastUpdateTime: lastUpdateTime,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MetaCount &&
          const DeepCollectionEquality().equals(other.roomId, roomId) &&
          const DeepCollectionEquality()
              .equals(other.mediasCount, mediasCount) &&
          const DeepCollectionEquality().equals(other.filesCount, filesCount) &&
          const DeepCollectionEquality().equals(other.callsCount, callsCount) &&
          const DeepCollectionEquality()
              .equals(other.voicesCount, voicesCount) &&
          const DeepCollectionEquality()
              .equals(other.musicsCount, musicsCount) &&
          const DeepCollectionEquality().equals(other.linkCount, linkCount) &&
          const DeepCollectionEquality()
              .equals(other.allVoicesDeletedCount, allVoicesDeletedCount) &&
          const DeepCollectionEquality()
              .equals(other.allMediaDeletedCount, allMediaDeletedCount) &&
          const DeepCollectionEquality()
              .equals(other.allLinksDeletedCount, allLinksDeletedCount) &&
          const DeepCollectionEquality()
              .equals(other.allCallDeletedCount, allCallDeletedCount) &&
          const DeepCollectionEquality()
              .equals(other.allMusicsDeletedCount, allMusicsDeletedCount) &&
          const DeepCollectionEquality()
              .equals(other.allFilesDeletedCount, allFilesDeletedCount));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomId),
        const DeepCollectionEquality().hash(mediasCount),
        const DeepCollectionEquality().hash(filesCount),
        const DeepCollectionEquality().hash(callsCount),
        const DeepCollectionEquality().hash(voicesCount),
        const DeepCollectionEquality().hash(musicsCount),
        const DeepCollectionEquality().hash(linkCount),
        const DeepCollectionEquality().hash(allLinksDeletedCount),
        const DeepCollectionEquality().hash(allCallDeletedCount),
        const DeepCollectionEquality().hash(allMediaDeletedCount),
        const DeepCollectionEquality().hash(allMusicsDeletedCount),
        const DeepCollectionEquality().hash(allFilesDeletedCount),
        const DeepCollectionEquality().hash(allVoicesDeletedCount),
      );

  @override
  String toString() {
    return 'MediaMetaData{roomId: $roomId, mediasCount: $mediasCount, filesCount: $filesCount, callsCount: $callsCount, voicesCount: $voicesCount, musicsCount: $musicsCount, linkCount: $linkCount, lastUpdateTime: $lastUpdateTime}';
  }
}
