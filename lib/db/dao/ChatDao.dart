import 'package:moor/moor.dart';

import '../Chats.dart';
import '../database.dart';
part 'ChatDao.g.dart';

@UseDao(tables: [Chats])
class ChatDao extends DatabaseAccessor<Database> with _$ChatDaoMixin {
  final Database db;
  ChatDao(this.db) : super(db);
}
