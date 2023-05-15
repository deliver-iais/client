
import 'package:deliver/box/file_info.dart';

abstract class FileDao {
  Future<FileInfo?> get(String uuid, String sizeType);

  Future<void> save(FileInfo fileInfo);

  Future<void> remove(String size, String uuid);
}

