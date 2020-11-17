import 'dart:html';

import 'package:deliver_flutter/db/MediaMetaData.dart';
import 'package:moor/moor.dart';
import '../database.dart';
part 'MediaMetaDataDao.g.dart';

@UseDao(tables: [MediasMetaData])
class MediaMetaDataDao extends DatabaseAccessor<Database> with _$MediaMetaDataDaoMixin {
  final Database database;

  MediaMetaDataDao(this.database) : super(database);

  Future insertMetaData(MediasMetaDataData media) =>
    into(mediasMetaData).insertOnConflictUpdate(media);

  Future<MediasMetaDataData> getMediasCountByRoomId(String roomId) {
    return (select(mediasMetaData)
      ..where((meta) => meta.roomId.equals(roomId))).getSingle();
  }
}
