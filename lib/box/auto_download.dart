import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'auto_download.g.dart';

@HiveType(typeId: AUTO_DOWNLOAD_TRACK_ID)
class AutoDownload {
  @HiveField(0)
  bool photoAutoDownload;

  @HiveField(1)
  bool fileAutoDownload;

  @HiveField(2)
  int fileAutoDownloadSize;

  @HiveField(3)
  AutoDownloadRoomCategory roomCategory;

  AutoDownload({
    this.photoAutoDownload = false,
    this.fileAutoDownload = false,
    this.fileAutoDownloadSize = 0,
    required this.roomCategory,
  });

  AutoDownload copyWith({
    bool? photoAutoDownload,
    bool? fileAutoDownload,
    int? fileAutoDownloadSize,
    AutoDownloadRoomCategory? roomCategory,
  }) =>
      AutoDownload(
        photoAutoDownload: photoAutoDownload ?? this.photoAutoDownload,
        fileAutoDownload: fileAutoDownload ?? this.fileAutoDownload,
        fileAutoDownloadSize: fileAutoDownloadSize ?? this.fileAutoDownloadSize,
        roomCategory: roomCategory ?? this.roomCategory,
      );
}
