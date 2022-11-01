import 'package:deliver/box/auto_download.dart';
import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:hive/hive.dart';

abstract class AutoDownloadDao extends DBManager {
  Future<bool> isPhotoAutoDownloadEnable(AutoDownloadRoomCategory category);

  Future<bool> isFileAutoDownloadEnable(AutoDownloadRoomCategory category);

  Future<void> enablePhotoAutoDownload(AutoDownloadRoomCategory category);

  Future<void> disablePhotoAutoDownload(AutoDownloadRoomCategory category);

  Future<void> enableFileAutoDownload(AutoDownloadRoomCategory category);

  Future<void> disableFileAutoDownload(AutoDownloadRoomCategory category);

  Future<void> setFileSizeLimitForAutoDownload(
    AutoDownloadRoomCategory category,
    int size,
  );

  Future<int> getFileSizeLimitForAutoDownload(
    AutoDownloadRoomCategory category,
  );

  AutoDownloadRoomCategory convertCategory(Categories categories);
}

class AutoDownloadDaoImpl extends AutoDownloadDao {
  static String _key() => "auto_download";

  Future<BoxPlus<AutoDownload>> _open() {
    super.open(_key(), AUTO_DOWNLOAD_TABLE_NAME);
    return gen(Hive.openBox<AutoDownload>(_key()));
  }

  @override
  Future<void> disableFileAutoDownload(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    final auto = box.get(category.toString()) ??
        AutoDownload(
          roomCategory: category,
        );
    return box.put(category.toString(), auto.copyWith(fileAutoDownload: false));
  }

  @override
  Future<void> disablePhotoAutoDownload(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    final auto = box.get(category.toString()) ??
        AutoDownload(
          roomCategory: category,
        );
    return box.put(
      category.toString(),
      auto.copyWith(photoAutoDownload: false),
    );
  }

  @override
  Future<void> enableFileAutoDownload(AutoDownloadRoomCategory category) async {
    final box = await _open();
    final auto = box.get(category.toString()) ??
        AutoDownload(
          roomCategory: category,
        );
    return box.put(category.toString(), auto.copyWith(fileAutoDownload: true));
  }

  @override
  Future<void> enablePhotoAutoDownload(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    final auto = box.get(category.toString()) ??
        AutoDownload(
          roomCategory: category,
        );
    return box.put(category.toString(), auto.copyWith(photoAutoDownload: true));
  }

  @override
  Future<bool> isFileAutoDownloadEnable(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    return box.get(category.toString())?.fileAutoDownload ?? false;
  }

  @override
  Future<bool> isPhotoAutoDownloadEnable(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    return box.get(category.toString())?.photoAutoDownload ?? false;
  }

  @override
  AutoDownloadRoomCategory convertCategory(Categories categories) {
    switch (categories) {
      case Categories.USER:
      case Categories.BOT:
      case Categories.SYSTEM:
      case Categories.STORE:
        return AutoDownloadRoomCategory.IN_PRIVATE_CHATS;
      case Categories.CHANNEL:
        return AutoDownloadRoomCategory.IN_CHANNEL;
      case Categories.GROUP:
        return AutoDownloadRoomCategory.IN_GROUP;
    }
    return AutoDownloadRoomCategory.IN_PRIVATE_CHATS;
  }

  @override
  Future<void> setFileSizeLimitForAutoDownload(
    AutoDownloadRoomCategory category,
    int size,
  ) async {
    final box = await _open();
    final auto = box.get(category.toString()) ??
        AutoDownload(
          roomCategory: category,
        );
    return box.put(
      category.toString(),
      auto.copyWith(fileAutoDownloadSize: size),
    );
  }

  @override
  Future<int> getFileSizeLimitForAutoDownload(
    AutoDownloadRoomCategory category,
  ) async {
    final box = await _open();
    return box.get(category.toString())?.fileAutoDownloadSize ?? 1;
  }
}
