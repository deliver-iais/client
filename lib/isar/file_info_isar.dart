import 'package:deliver/box/file_info.dart';
import 'package:isar/isar.dart';

part 'file_info_isar.g.dart';

@collection
class FileInfoIsar {
  Id id = Isar.autoIncrement;

  final String name;

  final String uuid;

  @Index(type: IndexType.hash)
  final String sizeType;

  final String path;

  FileInfoIsar({
    required this.name,
    required this.uuid,
    required this.sizeType,
    required this.path,
  });

  FileInfo fromIsar() => FileInfo(
        uuid: uuid,
        name: name,
        path: path,
        sizeType: sizeType,
      );
}

extension FileInfoIsarMapper on FileInfo {
  FileInfoIsar toIsar() => FileInfoIsar(
        uuid: uuid,
        name: name,
        sizeType: sizeType,
        path: path,
      );
}
