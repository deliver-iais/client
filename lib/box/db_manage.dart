import 'dart:async';

import 'package:collection/collection.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/dao/box_dao.dart';

const ACCOUNT = "ACCOUNT";
const ACTIVE_NOTIFICATION = "ACTIVE_NOTIFICATION";
const AUTO_DOWNLOAD = "AUTO_DOWNLOAD";
const AUTO_DOWNLOAD_ROOM_CATEGORY = "AUTO_DOWNLOAD_ROOM_CATEGORY";
const AVATAR = "AVATAR";
const BLOCK = "BLOCK";
const BOT_INFO = "BOT_INFO";
const CALL_EVENT = "CALL_EVENT";
const CALL_INF0 = "CALL_INF0";
const CALL_STATUS = "CALL_STATUS";
const CALL_TYPE = "CALL_TYPE";
const CONTACT = "CONTACT";
const CURRENT_CALL_INFO = "CURRENT_CALL_INFO";
const FILE_INFO = "FILE_INFO";
const LAST_ACTIVITY = "LAST_ACTIVITY";
const LIVE_LOCATION = "LIVE_LOCATION";
const MEDIA = "MEDIA";
const MEDIA_META_DATA = "MEDIA_META_DATA";
const MEDIA_TYPE = "MEDIA_TYPE";
const MEMBER = "MEMBER";
const MESSAGE = "MESSAGE";
const MESSAGE_BRIEF = "MESSAGE_BRIEF";
const MESSAGE_TYPE = "MESSAGE_TYPE";
const MUC = "MUC";
const MUTE = "MUTE";
const PENDING_MESSAGE = "PENDING_MESSAGE";
const EDIT_PENDING = "EDIT_PENDING";
const ROLE = "ROLE";
const ROOM = "ROOM";
const MY_SEEN = "MY_SEEN";
const OTHER_SEEN = "OTHER_SEEN";
const SENDING_STATUS = "SENDING_STATUS";
const SHOW_CASE = "SHOW_CASE";
const UID_ID_NAME = "UID_ID_NAME";
const ID_UID_NAME = "ID_UID_NAME";
const CUSTOM_NOTIFICATION = "CUSTOM_NOTIFICATION";
const SHARED = "SHARED";

class DBManager {
  Map<String, int> _getDbVersions() => {
        ACCOUNT: 1,
        ACTIVE_NOTIFICATION: 1,
        AUTO_DOWNLOAD: 1,
        AUTO_DOWNLOAD_ROOM_CATEGORY: 1,
        AVATAR: 1,
        BLOCK: 1,
        BOT_INFO: 1,
        CALL_INF0: 1,
        CONTACT: 1,
        CURRENT_CALL_INFO: 1,
        FILE_INFO: 1,
        LAST_ACTIVITY: 1,
        LIVE_LOCATION: 1,
        MEDIA: 1,
        MEDIA_META_DATA: 1,
        MEMBER: 1,
        MESSAGE: 1,
        MESSAGE_BRIEF: 1,
        MUC: 1,
        MUTE: 1,
        PENDING_MESSAGE: 1,
        ROOM: 1,
        MY_SEEN: 1,
        OTHER_SEEN: 1,
        SENDING_STATUS: 1,
        SHOW_CASE: 1,
        UID_ID_NAME: 1,
        ID_UID_NAME: 1,
        CUSTOM_NOTIFICATION: 1,
        EDIT_PENDING: 1,
        SHARED: 1,
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
