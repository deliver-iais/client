import 'dart:async';

import 'package:collection/collection.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/dao/box_dao.dart';

const ACCOUNT_TABLE_NAME = "ACCOUNT";
const ACTIVE_NOTIFICATION_TABLE_NAME = "ACTIVE_NOTIFICATION";
const AUTO_DOWNLOAD_TABLE_NAME = "AUTO_DOWNLOAD";
const AUTO_DOWNLOAD_ROOM_CATEGORY_TABLE_NAME = "AUTO_DOWNLOAD_ROOM_CATEGORY";
const AVATAR_TABLE_NAME = "AVATAR";
const BLOCK_TABLE_NAME = "BLOCK";
const BOT_INFO_TABLE_NAME = "BOT_INFO";
const CALL_EVENT_TABLE_NAME = "CALL_EVENT";
const CALL_INFO_TABLE_NAME = "CALL_INFO";
const CALL_STATUS_TABLE_NAME = "CALL_STATUS";
const CALL_TYPE_TABLE_NAME = "CALL_TYPE";
const CONTACT_TABLE_NAME = "CONTACT";
const CURRENT_CALL_INFO_TABLE_NAME = "CURRENT_CALL_INFO";
const FILE_INFO_TABLE_NAME = "FILE_INFO";
const LAST_ACTIVITY_TABLE_NAME = "LAST_ACTIVITY";
const LIVE_LOCATION_TABLE_NAME = "LIVE_LOCATION";
const MEDIA_TABLE_NAME = "MEDIA";
const MEDIA_META_DATA_TABLE_NAME = "MEDIA_META_DATA";
const MEDIA_TYPE_TABLE_NAME = "MEDIA_TYPE";
const MEMBER_TABLE_NAME = "MEMBER";
const MESSAGE_TABLE_NAME = "MESSAGE";
const MESSAGE_BRIEF_TABLE_NAME = "MESSAGE_BRIEF";
const MESSAGE_TYPE_TABLE_NAME = "MESSAGE_TYPE";
const MUC_TABLE_NAME = "MUC";
const MUTE_TABLE_NAME = "MUTE";
const PENDING_MESSAGE_TABLE_NAME = "PENDING_MESSAGE";
const EDIT_PENDING_TABLE_NAME = "EDIT_PENDING";
const ROLE_TABLE_NAME = "ROLE";
const ROOM_TABLE_NAME = "ROOM";
const MY_SEEN_TABLE_NAME = "MY_SEEN";
const OTHER_SEEN_TABLE_NAME = "OTHER_SEEN";
const SENDING_STATUS_TABLE_NAME = "SENDING_STATUS";
const SHOW_CASE_TABLE_NAME = "SHOW_CASE";
const UID_ID_NAME_TABLE_NAME = "UID_ID_NAME";
const ID_UID_NAME_TABLE_NAME = "ID_UID_NAME";
const CUSTOM_NOTIFICATION_TABLE_NAME = "CUSTOM_NOTIFICATION";
const SHARED_TABLE_NAME = "SHARED";

class DBManager {
  Map<String, int> _getDbVersions() => {
        ACCOUNT_TABLE_NAME: 1,
        ACTIVE_NOTIFICATION_TABLE_NAME: 1,
        AUTO_DOWNLOAD_TABLE_NAME: 1,
        AUTO_DOWNLOAD_ROOM_CATEGORY_TABLE_NAME: 1,
        AVATAR_TABLE_NAME: 1,
        BLOCK_TABLE_NAME: 1,
        BOT_INFO_TABLE_NAME: 1,
        CALL_INFO_TABLE_NAME: 1,
        CONTACT_TABLE_NAME: 1,
        CURRENT_CALL_INFO_TABLE_NAME: 1,
        FILE_INFO_TABLE_NAME: 1,
        LAST_ACTIVITY_TABLE_NAME: 1,
        LIVE_LOCATION_TABLE_NAME: 1,
        MEDIA_TABLE_NAME: 1,
        MEDIA_META_DATA_TABLE_NAME: 1,
        MEMBER_TABLE_NAME: 1,
        MESSAGE_TABLE_NAME: 1,
        MESSAGE_BRIEF_TABLE_NAME: 1,
        MUC_TABLE_NAME: 1,
        MUTE_TABLE_NAME: 1,
        PENDING_MESSAGE_TABLE_NAME: 1,
        ROOM_TABLE_NAME: 1,
        MY_SEEN_TABLE_NAME: 1,
        OTHER_SEEN_TABLE_NAME: 1,
        SENDING_STATUS_TABLE_NAME: 1,
        SHOW_CASE_TABLE_NAME: 1,
        UID_ID_NAME_TABLE_NAME: 1,
        ID_UID_NAME_TABLE_NAME: 1,
        CUSTOM_NOTIFICATION_TABLE_NAME: 1,
        EDIT_PENDING_TABLE_NAME: 1,
        SHARED_TABLE_NAME: 1,
      };

  void open(String key, String dbName) => BoxDao.addBox(
        key,
        BoxInfo(
          dbKey: key,
          name: dbName,
          version: _getDbVersions()[dbName] ?? 1,
        ),
      );

  Future<void> deleteDB({bool deleteSharedDao = true}) async {
    try {
      return BoxDao.deleteAllBox(deleteSharedDao: deleteSharedDao);
    } catch (_) {}
  }

  int getDbVersion() => const DeepCollectionEquality().hash(_getDbVersions());

  Future<void> migrate({
    bool deleteSharedDao = true,
    bool removeOld = false,
  }) async {
    final boxes = await BoxDao.getAll();
    if (removeOld) {
      await (BoxDao.removeOldDb(deleteSharedDao: deleteSharedDao));
    } else {
      for (final boxInfo in boxes) {
        if (boxInfo.version != _getDbVersions()[boxInfo.name] &&
            (!deleteSharedDao || boxInfo.dbKey != "shared")) {
          unawaited(BoxDao.deleteBox(boxInfo.dbKey));
        }
      }
    }
  }
}
