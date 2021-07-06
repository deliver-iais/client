


import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';


part 'database.g.dart';

@UseMoor(tables: [


], daos: [


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
        onUpgrade: (migrator, from, to) async {},
        beforeOpen: (details) async {},
      );
}
