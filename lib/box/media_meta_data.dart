
import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'media_meta_data.g.dart';

@HiveType(typeId: MEDIA_META_DATA_TRACK_ID)
class MediaMetaData {

  // DbId
  @HiveField(0)
  String roomId;

  @HiveField(1)
  int  imagesCount ;

  @HiveField(2)
  int videosCount;

  @HiveField(3)
  int filesCount;

  @HiveField(4)
  int documentsCount;

  @HiveField(5)
  int audiosCount;

  @HiveField(6)
  int musicsCount;

  @HiveField(7)
  int linkCount;

  MediaMetaData({
      this.roomId,
      this.imagesCount,
      this.videosCount,
      this.filesCount,
      this.documentsCount,
      this.audiosCount,
      this.musicsCount,
      this.linkCount});
}