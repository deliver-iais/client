import 'package:moor/moor.dart';

import '../StickerId.dart';
import '../database.dart';

part 'StickerIdDao.g.dart';

@UseDao(tables: [StickerIds])
class StickerIdDao extends DatabaseAccessor<Database> with _$StickerIdDaoMixin {
  final Database database;

  StickerIdDao(this.database) : super(database);

  upsertStickerPack(StickerId stickerId) {
    into(stickerIds).insertOnConflictUpdate(stickerId);
  }

  Future<List<StickerId>> getStickerIds() {
    return (select(stickerIds).get());
  }

  Stream<List<StickerId>> getNotDownloadStickerPackId() {
    return (select(stickerIds)
          ..where((tbl) => tbl.packISDownloaded.equals(false))
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.getPackTime, mode: OrderingMode.asc)
          ]))
        .watch();
  }
}
