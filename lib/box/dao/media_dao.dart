import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:hive/hive.dart';

abstract class MediaDao extends DBManager {
  Future<List<Media>> get(String roomId, MediaType type, int limit, int offset);

  Future<List<Media>> getByRoomIdAndType(String roomUid, MediaType type);

  Future save(Media media);

  Future<int?> getIndexOfMedia(String roomUid, int messageId, MediaType type);

  Stream<int> getIndexOfMediaAsStream(
    String roomUid,
    int messageId,
    MediaType type,
  );

  Future<void> deleteMedia(String roomId, int messageId);

  Future clear(String roomId);
}

class MediaDaoImpl extends MediaDao {
  @override
  Future<List<Media>> get(
    String roomId,
    MediaType type,
    int limit,
    int offset,
  ) async {
    final box = await _open(roomId);
    final res = <Media>[];
    final medias = box.values
        .where(
          (element) => element.roomId.contains(roomId) && element.type == type,
        )
        .toList()
        .sublist(offset, offset + limit);
    return res
      ..addAll(medias)
      ..sort((a, b) => a.createdOn - b.createdOn);
  }

  @override
  Future<void> save(Media media) async {
    final box = await _open(media.roomId);
    return box.put(media.messageId, media);
  }

  @override
  Future<int?> getIndexOfMedia(
    String roomUid,
    int messageId,
    MediaType type,
  ) async {
    final box = await _open(roomUid);

    return box.values
        .where((element) => element.type == type)
        .toList()
        .reversed
        .toList()
        .indexWhere(
          (element) => element.messageId == messageId,
        );
  }

  @override
  Stream<int> getIndexOfMediaAsStream(
    String roomUid,
    int messageId,
    MediaType type,
  ) async* {
    final box = await _open(roomUid);

    yield box.values
        .where((element) => element.type == type)
        .toList()
        .reversed
        .toList()
        .indexWhere(
          (element) => element.messageId == messageId,
        );

    yield* box.watch().map(
          (event) => box.values
              .where((element) => element.type == type)
              .toList()
              .reversed
              .toList()
              .indexWhere(
                (element) => element.messageId == messageId,
              ),
        );
  }

  @override
  Future<List<Media>> getByRoomIdAndType(String roomUid, MediaType type) async {
    final box = await _open(roomUid);

    return sorted(
      box.values
          .where(
            (element) =>
                element.roomId.contains(roomUid) && element.type == type,
          )
          .toList(),
    );
  }

  List<Media> sorted(List<Media> list) {
    list.sort((a, b) => (b.messageId) - (a.messageId));
    return list;
  }

  @override
  Future<void> deleteMedia(String roomId, int messageId) async {
    final box = await _open(roomId);
    return box.delete(messageId);
  }

  @override
  Future clear(String roomId) async {
    final box = await _open(roomId);
    await box.clear();
  }

  static String _key(String roomUid) => "media-$roomUid";

  Future<BoxPlus<Media>> _open(String uid) {
    super.open(_key(uid.replaceAll(":", "-")), MEDIA);
    return gen(Hive.openBox<Media>(_key(uid.replaceAll(":", "-"))));
  }
}
