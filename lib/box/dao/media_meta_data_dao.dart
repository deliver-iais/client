import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:hive/hive.dart';

abstract class MediaMetaDataDao {
  Future save(MediaMetaData mediaMetaData);

  Stream<MediaMetaData?> get(String roomUid);

  Future<MediaMetaData?> getAsFuture(String roomUid);
}

class MediaMetaDataDaoImpl implements MediaMetaDataDao {
  @override
  Stream<MediaMetaData?> get(String roomUid) async* {
    try{
      var box = await _open();
      yield box.values.where((element) => element.roomId.contains(roomUid)).first;
    }catch(e){

    }


  }

  @override
  Future<void> save(MediaMetaData mediaMetaData) async {
    var box = await _open();
    box.put(mediaMetaData.roomId, mediaMetaData);
  }

  static String _key() => "media_meta_data";

  static Future<Box<MediaMetaData>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<MediaMetaData>(_key());
  }

  @override
  Future<MediaMetaData?> getAsFuture(String roomUid) async {
    var box = await _open();
    try {
      return box.values.firstWhere((element) => element.roomId == roomUid);
    } catch (e) {
      return null;
    }
  }
}
