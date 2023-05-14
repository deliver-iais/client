import 'package:deliver/box/file_info.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'file_info_hive.g.dart';

@HiveType(typeId: FILE_INFO_TRACK_ID)
class FileInfoHive {
  // Table Name
  @HiveField(0)
  String sizeType;

  // DbId
  @HiveField(1)
  String uuid;

  @HiveField(2)
  String name;

  @HiveField(3)
  String path;

  FileInfoHive({
    required this.sizeType,
    required this.uuid,
    required this.name,
    required this.path,
  });

  FileInfoHive copyWith({
    String? sizeType,
    required String uuid,
    String? name,
    String? path,
  }) =>
      FileInfoHive(
        sizeType: sizeType ?? this.sizeType,
        uuid: uuid,
        name: name ?? this.name,
        path: path ?? this.path,
      );

  FileInfo fromHive() => FileInfo(
        uuid: uuid,
        name: name,
        path: path,
        sizeType: sizeType,
      );
}

extension FileInfoHiveMapper on FileInfo {
  FileInfoHive toHive() => FileInfoHive(
        uuid: uuid,
        name: name,
        sizeType: sizeType,
        path: path,
      );
}
