import 'package:deliver_flutter/db/MediaMetaData.dart';
import 'package:moor/moor.dart';
import '../database.dart';
part 'MediaMetaDataDao.g.dart';

@UseDao(tables: [MediasMetaData])
class MediaMetaDataDao extends DatabaseAccessor<Database> with _$MediaMetaDataDaoMixin {
  final Database database;

  MediaMetaDataDao(this.database) : super(database);
}
  // Future insertQueryMedia(Media media) =>
  //     into(MediasMetaData()).insertOnConflictUpdate(media);