import 'package:moor/moor.dart';

class Contacts extends Table {

  TextColumn get username => text().nullable()();

  TextColumn get uid => text().nullable()();

  TextColumn get phoneNumber => text()();

  TextColumn get firstName => text().nullable()();

  TextColumn get lastName => text().nullable()();

  BoolColumn get isMute => boolean()();

  BoolColumn get isBlock => boolean()();

  @override
  Set<Column> get primaryKey => {phoneNumber};
}
