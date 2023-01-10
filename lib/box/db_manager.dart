import 'dart:async';

import 'package:collection/collection.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/dao/box_dao.dart';

enum TableInfo {
  ACCOUNT_TABLE_NAME("ACCOUNT", 1),
  ACTIVE_NOTIFICATION_TABLE_NAME("ACTIVE_NOTIFICATION", 1),
  AUTO_DOWNLOAD_TABLE_NAME("AUTO_DOWNLOAD", 1),
  AUTO_DOWNLOAD_ROOM_CATEGORY_TABLE_NAME("AUTO_DOWNLOAD_ROOM_CATEGORY", 1),
  AVATAR_TABLE_NAME("AVATAR", 1),
  BLOCK_TABLE_NAME("BLOCK", 1),
  BOT_INFO_TABLE_NAME("BOT_INFO", 1),
  CALL_EVENT_TABLE_NAME("CALL_EVENT", 1),
  CALL_INFO_TABLE_NAME("CALL_INFO", 1),
  CALL_STATUS_TABLE_NAME("CALL_STATUS", 1),
  CALL_TYPE_TABLE_NAME("CALL_TYPE", 1),
  CONTACT_TABLE_NAME("CONTACT", 1),
  CURRENT_CALL_INFO_TABLE_NAME("CURRENT_CALL_INFO", 1),
  FILE_INFO_TABLE_NAME("FILE_INFO", 1),
  LAST_ACTIVITY_TABLE_NAME("LAST_ACTIVITY", 1),
  LIVE_LOCATION_TABLE_NAME("LIVE_LOCATION", 1),
  MEDIA_TABLE_NAME("MEDIA", 2),
  MEDIA_META_DATA_TABLE_NAME("MEDIA_META_DATA", 1),
  MEDIA_TYPE_TABLE_NAME("MEDIA_TYPE", 1),
  MEMBER_TABLE_NAME("MEMBER", 1),
  MESSAGE_TABLE_NAME("MESSAGE", 1),
  MESSAGE_BRIEF_TABLE_NAME("MESSAGE_BRIEF", 1),
  MESSAGE_TYPE_TABLE_NAME("MESSAGE_TYPE", 1),
  MUC_TABLE_NAME("MUC", 1),
  MUTE_TABLE_NAME("MUTE", 1),
  PENDING_MESSAGE_TABLE_NAME("PENDING_MESSAGE", 2),
  EDIT_PENDING_TABLE_NAME("EDIT_PENDING", 1),
  ROLE_TABLE_NAME("ROLE", 1),
  ROOM_TABLE_NAME("ROOM", 2),
  MY_SEEN_TABLE_NAME("MY_SEEN", 1),
  OTHER_SEEN_TABLE_NAME("OTHER_SEEN", 1),
  SENDING_STATUS_TABLE_NAME("SENDING_STATUS", 1),
  SHOW_CASE_TABLE_NAME("SHOW_CASE", 1),
  UID_ID_NAME_TABLE_NAME("UID_ID_NAME", 1),
  ID_UID_NAME_TABLE_NAME("ID_UID_NAME", 1),
  CUSTOM_NOTIFICATION_TABLE_NAME("CUSTOM_NOTIFICATION", 1),
  RECENT_EMOJI_TABLE_NAME("RECENT_EMOJI", 1),
  EMOJI_SKIN_TONE_TABLE_NAME("EMOJI_SKIN_TONE", 1),
  RECENT_ROOMS_TABLE_NAME("RECENT_ROOMS", 1),
  RECENT_SEARCH_TABLE_NAME("RECENT_SEARCH", 1),
  SHARED_TABLE_NAME("SHARED", 1);

  final String name;
  final int version;

  const TableInfo(this.name, this.version);

  @override
  String toString() => '${name}_TABLE_NAME';
}

class DBManager {
  static void open(String key, TableInfo table) => BoxDao.addBox(
        key,
        BoxInfo(dbKey: key, name: table.name, version: table.version),
      );

  Future<void> deleteDB({bool deleteSharedDao = true}) async {
    try {
      return BoxDao.deleteAllBox(deleteSharedDao: deleteSharedDao);
    } catch (_) {}
  }

  TableInfo? getTableInfo(String name) =>
      TableInfo.values.firstWhereOrNull((ti) => ti.name == name);

  int getDbVersionHashcode() {
    return const DeepCollectionEquality()
        .hash(TableInfo.values.map((e) => "${e.name}-${e.version}"));
  }

  Future<void> migrate({
    bool removeOld = false,
  }) async {
    final boxes = await BoxDao.getAll();

    // Remove Older Tables than version "1.9.7"
    if (removeOld) {
      await (BoxDao.removeOldDb());
    }

    for (final boxInfo in boxes) {
      if (boxInfo.version != getTableInfo(boxInfo.name)?.version) {
        unawaited(BoxDao.deleteBox(boxInfo.dbKey));
      }
    }
  }
}
