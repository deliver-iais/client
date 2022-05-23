import 'package:deliver/box/box_info.dart';

class DBManager {
  Future<void> deleteDB({bool deleteSharedDao=true}) async {
    try {
      return BoxInfo.deleteAllBox(deleteSharedDao: deleteSharedDao);
    } catch (_) {}
  }

  Future<void> migrate(String? previousVersion) async {}
}
