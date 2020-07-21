
import 'package:deliver_flutter/db/Avatars.dart';
import 'package:moor_flutter/moor_flutter.dart';
import '../database.dart';

part 'AvatarDao.g.dart';

@UseDao(tables: [Avatars])

class AvatarDao extends DatabaseAccessor<Database> with _$AvatarDaoMixin{
  final Database database;
  AvatarDao(this.database) : super(database);

}

