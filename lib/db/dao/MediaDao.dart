import 'package:deliver_flutter/db/Media.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:moor/moor.dart';

part 'MediaDao.g.dart';

@UseDao(tables: [Medias])
class MediaDao extends DatabaseAccessor<Database>
    with _$MediaDaoMixin {
  final Database database;

  MediaDao(this.database) : super(database);

  Future insertQueryMedia(Media media) =>
      into(medias).insertOnConflictUpdate(media);

  Future<List<Media>> getByRoomId(String roomId) {
    return (select(medias)
          ..where((media) => media.roomId.equals(roomId)))
        .get();
  }
}
