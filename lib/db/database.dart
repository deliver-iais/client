import 'package:deliver_flutter/db/Avatars.dart';
import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'Contacts.dart';
import 'FileInfo.dart';
import 'Rooms.dart';
import 'Seens.dart';
import 'dao/RoomDao.dart';
import 'dao/MessageDao.dart';

part 'database.g.dart';

@UseMoor(
    tables: [Messages, Rooms, Avatars, Contacts, FileInfos, Seens],
    daos: [MessageDao, RoomDao, AvatarDao, ContactDao, FileDao, SeenDao])
class Database extends _$Database {
  Database()
      : super(LazyDatabase(() async {
          // put the database file, called db.sqlite here, into the documents folder
          // for your app.
          final dbFolder = await getApplicationDocumentsDirectory();
          final file = File(p.join(dbFolder.path, 'db.sqlite'));
          return VmDatabase(file, logStatements: true);
        }));

  @override
  int get schemaVersion => 7;

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
