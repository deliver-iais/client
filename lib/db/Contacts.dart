import 'package:moor/moor.dart';

class Contacts extends Table {
  TextColumn get uid => text()();

  DateTimeColumn get lastUpdateAvatarTime => dateTime()();

  TextColumn get lastAvatarFileId => text().nullable()();

  TextColumn get phoneNumber => text()();

  TextColumn get firstName => text()();

  TextColumn get lastName => text()();

  DateTimeColumn get lastSeen => dateTime()();

  BoolColumn get notification => boolean()();

  BoolColumn get isBlock => boolean()();

  BoolColumn get isOnline => boolean()();

  @override
  Set<Column> get primaryKey => {uid};
}
