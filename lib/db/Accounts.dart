
import 'package:moor/moor.dart';

class Accounts extends Table {
  TextColumn get uid => text()();

  DateTimeColumn get loginTime => dateTime()();

  TextColumn get fileId => text()();
}
