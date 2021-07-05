import 'package:deliver_flutter/db/Media.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:moor/moor.dart';

part 'MediaDao.g.dart';

@UseDao(tables: [Medias])
class MediaDao extends DatabaseAccessor<Database> with _$MediaDaoMixin {
  final Database database;

  MediaDao(this.database) : super(database);

  Future insertQueryMedia(Media media) =>
      into(medias).insertOnConflictUpdate(media);

  Future<List<Media>> getByRoomIdAndType(String roomId, int type) {
    return (select(medias)
          ..orderBy([
            (medias) => OrderingTerm(
                expression: medias.createdOn, mode: OrderingMode.desc)
          ])
          ..where(
              (media) => media.roomId.equals(roomId) & media.type.equals(type)))
        .get();
  }

  Future<List<Media>> getMedia(String roomId, int type, int limit, int offset) {
    return (select(medias)
          ..orderBy([
            (medias) => OrderingTerm(
                expression: medias.createdOn, mode: OrderingMode.desc)
          ])
          ..where(
              (media) => media.roomId.equals(roomId) & media.type.equals(type))
          ..limit(limit, offset: offset))
        .get();
  }

  // Future<List<Media>> getByRoomId(String roomId) {
  //   return (select(medias)..where((media) => media.roomId.equals(roomId)))
  //       .get();
  // }

  Future<List<Media>> getAll() => select(medias).get();

  Future<List<Media>> getMediaAround(String roomId, int offset, int type) {
    if (offset - 1 < 0) {
      return (select(medias)
            ..orderBy([
              (medias) => OrderingTerm(
                  expression: medias.createdOn, mode: OrderingMode.desc)
            ])
            ..where((media) =>
                media.roomId.equals(roomId) & media.type.equals(type))
            ..limit(2, offset: offset))
          .get();
    } else {
      return (select(medias)
            ..orderBy([
              (medias) => OrderingTerm(
                  expression: medias.createdOn, mode: OrderingMode.desc)
            ])
            ..where((media) =>
                media.roomId.equals(roomId) & media.type.equals(type))
            ..limit(3, offset: offset - 1))
          .get();
    }
  }
}
