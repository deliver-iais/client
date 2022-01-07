

import 'package:deliver/box/box_info.dart';


class DBManager {
  Future<void> deleteDB() async {
    try {
      BoxInfo.deleteAllBox();
    } catch (_) {}

  }

  Future<void> migrate(String? previousVersion) async {}
}
