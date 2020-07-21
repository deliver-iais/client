import 'package:moor/moor.dart';

class Contacts extends Table{
  TextColumn get uid => text()();

  DateTimeColumn get lastUpdateAvatarTime => dateTime()();

  TextColumn get lastAvatarFileId => text()();

  TextColumn get phoneNumber => text()();

  TextColumn get displayName => text()();

  DateTimeColumn get  lastSeen => dateTime()();

  BoolColumn get notification => boolean()();

  BoolColumn get isBlock => boolean()();

  @override
  Set<Column> get primaryKey => {
    uid,
  };
}