

import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:hive/hive.dart';

abstract class MediaMetaDataDao{
  Future save(MediaMetaData mediaMetaData);

  Stream get (String roomUid);

}
class MediaMetaDataDaoImpl implements MediaMetaDataDao {
  get(String roomUid) async* {
    var box = await _open();
    yield box.values.where((element) => element.roomId.contains(roomUid));

  }

  Future<void> save(MediaMetaData mediaMetaData) async {

    var box = await _open();
    box.put(mediaMetaData.roomId, mediaMetaData);
  }

  static String _key() => "media_meta_data";

  static Future<Box<MediaMetaData>> _open() =>
      Hive.openBox<MediaMetaData>(_key());



}
