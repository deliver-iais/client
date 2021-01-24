import 'package:moor/moor.dart';

import '../StickerId.dart';
import '../database.dart';

part 'StickerIdDao.g.dart';

@UseDao(tables: [StickerIds])
class StickerIdDao extends DatabaseAccessor<Database> with _$StickerIdDaoMixin {
  final Database database;

  StickerIdDao(this.database) : super(database);

  addStickerId(StickerId stickerId) {
    into(stickerIds).insert(stickerId);
  }

  Future<List<StickerId>> getStickerIds() {
    return (select(stickerIds).get());
  }

  Future<List<StickerId>> getDownloadStickerPackId() {
    return (select(stickerIds)
          ..where((tbl) => tbl.packISDownloaded.equals(true))
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.getPackTime, mode: OrderingMode.asc)
          ]))
        .get();
  }
}
