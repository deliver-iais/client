import 'package:moor/moor.dart';

class Contacts extends Table{
  TextColumn get uid => text()();

  DateTimeColumn get lastUpdateAvatarTime => dateTime()();

  TextColumn get lastAvatarFileId => text()();
}