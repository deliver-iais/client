import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:hive/hive.dart';

abstract class MediaMetaDataDao extends DBManager {
  Future save(MediaMetaData mediaMetaData);

  Stream<MediaMetaData?> get(String roomUid);

  Future<MediaMetaData?> getAsFuture(String roomUid);

  Future clear(String roomUid);
}

class MediaMetaDataDaoImpl extends MediaMetaDataDao {
  @override
  Stream<MediaMetaData?> get(String roomUid) async* {
    final box = await _open();

    final res = box.values.where((element) => element.roomId.contains(roomUid));
    if (res.isNotEmpty) {
      yield res.first;
    }
    yield* box.watch().map(
          (event) => box.values
              .where((element) => element.roomId.contains(roomUid))
              .first,
        );
  }

  @override
  Future<void> save(MediaMetaData mediaMetaData) async {
    final box = await _open();
    return box.put(mediaMetaData.roomId, mediaMetaData);
  }

  @override
  Future<MediaMetaData?> getAsFuture(String roomUid) async {
    final box = await _open();
    try {
      return box.values.firstWhere((element) => element.roomId == roomUid);
    } catch (e) {
      return null;
    }
  }

  @override
  Future clear(String roomUid) async {
    final box = await _open();
    await box.delete(roomUid);
  }

  static String _key() => "media_meta_data";

  Future<BoxPlus<MediaMetaData>> _open() {
    super.open(_key(), MEDIA_META_DATA_TABLE_NAME);
    return gen(Hive.openBox<MediaMetaData>(_key()));
  }
}
