import 'package:deliver/isar/avatar_isar.dart';
import 'package:deliver/isar/file_info_isar.dart';
import 'package:deliver/isar/is_verified_isar.dart';
import 'package:deliver/isar/pending_message_isar.dart';
import 'package:deliver/isar/room_isar.dart';
import 'package:deliver/services/storage_path_service.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

class IsarManager {
  static Isar? _isar;

  static final _storagePathService = GetIt.I.get<StoragePathService>();

  static Future<Isar> open() async {
    final dir = await _storagePathService.localPathIsar;
    return _isar ??= Isar.openSync(
      [AvatarIsarSchema, PendingMessageIsarSchema, FileInfoIsarSchema,IsVerifiedIsarSchema,RoomIsarSchema],
      directory: dir,
    );
  }
}
