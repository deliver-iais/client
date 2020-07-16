import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor_flutter/moor_flutter.dart';

import 'Chats.dart';
import 'dao/ChatDao.dart';
import 'dao/MessageDao.dart';

part 'database.g.dart';

@UseMoor(tables: [Messages, Chats], daos: [MessageDao, ChatDao])
class Database extends _$Database {
  Database()
      : super(FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          logStatements: true,
        ));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 2) {
            await migrator.addColumn(messages, messages.content);
            await migrator.addColumn(messages, messages.seen);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
