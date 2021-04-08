import 'package:moor/moor.dart';

class BotInfos extends Table {
  TextColumn get description => text()();

  TextColumn get name => text().nullable()();

  TextColumn get username => text()();

  TextColumn get commands => text()();

  @override
  Set<Column> get  primaryKey =>{
    username
  };
}
