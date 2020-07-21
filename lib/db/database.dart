import 'package:deliver_flutter/db/Avatars.dart';
import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor_flutter/moor_flutter.dart';

import 'Rooms.dart';
import 'dao/RoomDao.dart';
import 'dao/MessageDao.dart';

part 'database.g.dart';

@UseMoor(tables: [Messages, Rooms,Avatars], daos: [MessageDao, RoomDao,AvatarDao])
class Database extends _$Database {
  Database()
      : super(FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          logStatements: true,
        ));

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
        },
      );
}
