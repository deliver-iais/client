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
  String path;

  @HiveField(4)
  List<int> bytes;

  FileInfo({this.sizeType, this.uuid, this.name, this.path,this.bytes});

  FileInfo copyWith({String sizeType, String uuid, String name, String path,List<int> bytes }) =>
      FileInfo(
        sizeType: sizeType ?? this.sizeType,
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        path: path ?? this.path,
        bytes: bytes ?? this.bytes,
      );
}
