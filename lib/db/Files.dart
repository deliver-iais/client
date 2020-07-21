import 'package:moor/moor.dart';

class Files extends Table{
  TextColumn get id  => text()();

  TextColumn get  path => text()();

  TextColumn get displayName => text()();



}