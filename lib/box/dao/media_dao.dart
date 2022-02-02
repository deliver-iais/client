import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:hive/hive.dart';

abstract class MediaDao {
  Future<List<Media>> get(String roomId, MediaType type, int limit, int offset);

  Future<List<Media>> getByRoomIdAndType(String roomUid, MediaType type);

  Future save(Media media);

  Future<List<Media>> getMediaAround(String roomId, int offset, MediaType type);

  Stream<List<Media>>? getMediaAsStream(String roomUid, MediaType mediaType);
}

class MediaDaoImpl implements MediaDao {
  @override
  get(String roomId, MediaType type, int limit, int offset) async {
    var box = await _open(roomId);
    List<Media> res = [];
    var medias = box.values
        .where((element) =>
            element.roomId.contains(roomId) && element.type == type)
        .toList()
        .sublist(offset, offset + limit);
    res.addAll(medias);
    res.sort((a, b) => a.createdOn - b.createdOn);
    return res;
  }

  @override
  Future<void> save(Media media) async {
    var box = await _open(media.roomId);
    box.put(media.messageId, media);
  }

  static String _key(String roomUid) => "media-$roomUid";

  static Future<Box<Media>> _open(String uid) {
    BoxInfo.addBox(_key(uid.replaceAll(":", "-")));
    return Hive.openBox<Media>(_key(uid.replaceAll(":", "-")));
  }

  @override
  Future<List<Media>> getByRoomIdAndType(String roomUid, MediaType type) async {
    var box = await _open(roomUid);
    List<Media> res = [];
    var medias = box.values
        .where((element) =>
            element.roomId.contains(roomUid) && element.type == type)
        .toList();
    res.addAll(medias);
    res.sort((a, b) => a.createdOn - b.createdOn);
    return res;
  }

  @override
  Stream<List<Media>>? getMediaAsStream(
      String roomUid, MediaType mediaType) async* {
    var box = await _open(roomUid);

    yield sorted(box.values
        .where((element) =>
            element.roomId.contains(roomUid) && element.type == mediaType)
        .toList());

    yield* box.watch().map((event) => sorted(box.values
        .where((element) =>
            element.roomId.contains(roomUid) && element.type == mediaType)
        .toList()));
  }

  List<Media> sorted(List<Media> list) {
    list.sort((a, b) => (b.messageId) - (a.messageId));
    return list;
  }

  @override
  Future<List<Media>> getMediaAround(
      String roomId, int offset, MediaType type) async {
    var box = await _open(roomId);
    List<Media> res = [];
    if (offset - 1 < 0) {
      var medias = box.values
          .where((element) =>
              element.roomId.contains(roomId) && element.type == type)
          .toList()
          .sublist(offset, offset + 1);

      res.addAll(medias);
      res.sort((a, b) => a.createdOn - b.createdOn);
      return res;
    } else {
      var medias = box.values
          .where((element) =>
              element.roomId.contains(roomId) && element.type == type)
          .toList()
          .sublist(offset - 1, offset + 2);
      res.addAll(medias);
      res.sort((a, b) => a.createdOn - b.createdOn);
      return res;
    }
  }
}
