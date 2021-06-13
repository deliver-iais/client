import 'package:deliver_flutter/db/Avatars.dart';
import 'package:deliver_flutter/db/BotInfos.dart';
import 'package:deliver_flutter/db/Media.dart';
import 'package:deliver_flutter/db/LastAvatar.dart';
import 'package:deliver_flutter/db/MediaMetaData.dart';
import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/db/SharedPreferences.dart';
import 'package:deliver_flutter/db/StickerId.dart';
import 'package:deliver_flutter/db/Stickers.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/BotInfoDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/LastAvatarDao.dart';
import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/dao/StickerIdDao.dart';
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'Contacts.dart';
import 'FileInfo.dart';
import 'Mucs.dart';
import 'LastSeen.dart';
import 'Member.dart';
import 'Rooms.dart';
import 'Seens.dart';
import 'PendingMessages.dart';
import 'UserInfos.dart';
import 'dao/LastSeenDao.dart';
import 'dao/MediaMetaDataDao.dart';
import 'dao/MemberDao.dart';
import 'dao/RoomDao.dart';
import 'dao/MessageDao.dart';

part 'database.g.dart';

@UseMoor(tables: [
  Messages,
  Rooms,
  Avatars,
  Contacts,
  FileInfos,
  Seens,
  LastAvatars,
  PendingMessages,
  Medias,
  SharedPreferences,
  Members,
  Mucs,
  LastSeens,
  MediasMetaData,
  UserInfos,
  Stickers,
  StickerIds,
  BotInfos
], daos: [
  MessageDao,
  RoomDao,
  AvatarDao,
  ContactDao,
  FileDao,
  SeenDao,
  LastAvatarDao,
  PendingMessageDao,
  MediaDao,
  SharedPreferencesDao,
  MemberDao,
  MucDao,
  LastSeenDao,
  MediaMetaDataDao,
  UserInfoDao,
  StickerDao,
  StickerIdDao,
  BotInfoDao
])
class Database extends _$Database {
  final PathProviderWindows provider = PathProviderWindows();


  Database()
      : super(LazyDatabase(() async {
          if (isDesktop()) {
            sqfliteFfiInit();
          }
          moorRuntimeOptions.dontWarnAboutMultipleDatabases = true;
          final dbFolder = await getApplicationDocumentsDirectory();
          final file = File(p.join(dbFolder.path, 'db.sqlite'));

          return VmDatabase(file, logStatements: false);
        }));

  @override
  int get schemaVersion => 7;

  Future<void> deleteAllData() {
    return transaction(() async {
      for (var table in allTables) {
        delete(table).go();
      }
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 6) {
            await migrator.createTable(rooms);
            await migrator.createTable(messages);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');

          // await customInsert(
          //     'INSERT INTO messages (room_id, id, time, `from`, `to`, edited, encrypted, type, content, seen) VALUES(5, 1, 1595158554, \'0000000000000000000000\', \'0000000000000000000001\', 0,0,0,\'hi\', 0)');

          // await customStatement(
          //     'INSERT INTO messages (room_id, id, time, `from`, `to`, edited, encrypted, type, content, seen) VALUES(5, 2, 1595158564, \'0000000000000000000000\', \'0000000000000000000001\', 0,0,0,\'hiddfff\', 0)');
          // final int roomId = await customInsert(
          //     'INSERT INTO rooms (room_id, `sender`, `reciever`, last_message) VALUES(5, \'0000000000000000000000\', \'0000000000000000000001\', 5)');
        },
      );
}
