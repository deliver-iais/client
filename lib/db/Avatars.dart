import 'package:deliver_flutter/generated-protocol/pub/v1/models/avatar.pb.dart';
import 'package:moor_flutter/moor_flutter.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  TextColumn get fileId => text()();

  IntColumn get  avatarIndex => integer()();

  @override
  Set<Column> get primaryKey => {uid,avatarIndex};
}
