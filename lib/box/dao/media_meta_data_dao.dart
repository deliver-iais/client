import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:hive/hive.dart';

abstract class MediaMetaDataDao {
  Future save(MediaMetaData mediaMetaData);

  Stream<MediaMetaData?> get(String roomUid);

  Future<MediaMetaData?> getAsFuture(String roomUid);

  Future clear(String roomUid);
}

class MediaMetaDataDaoImpl implements MediaMetaDataDao {
  @override
  Stream<MediaMetaData?> get(String roomUid) async* {
    try {
      final box = await _open();
      yield box.values
          .where((element) => element.roomId.contains(roomUid))
          .first;
    } catch (_) {}
  }

  @override
  Future<void> save(MediaMetaData mediaMetaData) async {
    final box = await _open();
    box.put(mediaMetaData.roomId, mediaMetaData);
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

  static Future<BoxPlus<MediaMetaData>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<MediaMetaData>(_key()));
  }
}
