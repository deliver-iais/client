import 'package:moor/moor.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  TextColumn get fileId => text()();

  DateTimeColumn get insertionDate => dateTime()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {uid,fileId};
}
