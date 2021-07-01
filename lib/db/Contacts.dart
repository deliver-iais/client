import 'package:moor/moor.dart';

class Contacts extends Table {

  TextColumn get username => text().nullable()();

  TextColumn get uid => text().nullable()();

  TextColumn get phoneNumber => text()();

  TextColumn get firstName => text().nullable()();

  TextColumn get lastName => text().nullable()();

  @override
  Set<Column> get primaryKey => {phoneNumber};
}

