import 'package:deliver_flutter/box/media.dart';
import 'package:deliver_flutter/box/media_type.dart';


import 'package:hive/hive.dart';
import 'package:sorted_list/sorted_list.dart';

abstract class MediaDao {
  Future<List<Media>> get(String roomId, MediaType type, int limit, int offset);

  Future<List<Media>> getByRoomIdAndType(String roomUid,MediaType type);

  Future save(Media media);

  Future <List<Media>> getMediaAround(String roomId, int offset, MediaType type);

}

class MediaDaoImpl implements MediaDao {
     get(String roomId, MediaType type, int limit, int offset) async {
    var box = await _open(roomId);
    var res = SortedList<Media>((a, b) => a.createdOn.compareTo(b.createdOn));
    var medias = box.values.where((element) => element.roomId.contains(roomId)&& element.type == type).toList().sublist(offset,offset+limit);
    res.addAll(medias);
    return res;
  }

  Future<void> save(Media media) async {

    var box = await _open(media.roomId);
    box.put(media.messageId, media);
  }

  static String _key(String roomUid) => "media-$roomUid";

  static Future<Box<Media>> _open(String roomUid) =>
      Hive.openBox<Media>(_key(roomUid));

  @override
  Future<List<Media>> getByRoomIdAndType(String roomUid,MediaType type) async {
    var box = await _open(roomUid);
    var res = SortedList<Media>((a, b) => a.createdOn.compareTo(b.createdOn));
    var medias = box.values.where((element) => element.roomId.contains(roomUid)&& element.type == type).toList();
    res.addAll(medias);
    return res;
  }

  @override
  Future<List<Media>> getMediaAround(String roomId, int offset, MediaType type) async{
    var box = await _open(roomId);
    if(offset-1<0){
      var  medias = box.values.where((element) => element.roomId.contains(roomId)&& element.type  == type).toList().sublist(offset,offset+1);
     var res = SortedList<Media>((a, b) => a.createdOn.compareTo(b.createdOn));
     res.addAll(medias);
     return res;
    }else{
      var  medias = box.values.where((element) => element.roomId.contains(roomId)&& element.type  == type).toList().sublist(offset-1,offset+2);
      var res = SortedList<Media>((a, b) => a.createdOn.compareTo(b.createdOn));
      res.addAll(medias);
      return res;

    }
  }
}
