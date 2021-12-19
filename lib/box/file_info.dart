import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'file_info.g.dart';

@HiveType(typeId: FILE_INFO_TRACK_ID)
class FileInfo {
  // Table Name
  @HiveField(0)
  String sizeType;

  // DbId
  @HiveField(1)
  String uuid;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? path;


  FileInfo(
      {required this.sizeType,
      required this.uuid,
      required this.name,
      this.path});

  FileInfo copyWith(
          {String? sizeType,
          required String uuid,
          String? name,
          String? path}) =>
      FileInfo(
        sizeType: sizeType ?? this.sizeType,
        uuid: uuid,
        name: name ?? this.name,
        path: path ?? this.path
      );
}
