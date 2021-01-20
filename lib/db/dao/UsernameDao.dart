
import 'package:deliver_flutter/db/Usernames.dart';
import 'package:moor/moor.dart';

import '../database.dart';

part 'UsernameDao.g.dart';

@UseDao(tables: [Usernames])
class UsernameDao extends DatabaseAccessor<Database> with _$UsernameDaoMixin {

  final Database database;
  UsernameDao(this.database) : super(database);

  insertUsername (Username username){
    into(usernames).insertOnConflictUpdate(username);
  }

 Future<Username> getUsername (String uid){
    return(select(usernames)..where((tbl) => tbl.uid.equals(uid))).getSingle();
  }

}