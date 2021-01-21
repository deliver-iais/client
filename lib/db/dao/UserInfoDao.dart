
import 'package:deliver_flutter/db/UserInfos.dart';
import 'package:moor/moor.dart';

import '../database.dart';

part 'UserInfoDao.g.dart';

@UseDao(tables: [UserInfos])
class UserInfoDao extends DatabaseAccessor<Database> with _$UserInfoDaoMixin {

  final Database database;
  UserInfoDao(this.database) : super(database);

  upsertUserInfo (UserInfo userInfo){
    into(userInfos).insertOnConflictUpdate(userInfo);
  }

 Future<UserInfo> getUserInfo (String uid){
    return(select(userInfos)..where((tbl) => tbl.uid.equals(uid))).getSingle();
  }

  Stream<UserInfo >getUserInfoAsStream(String uid) {
    return(select(userInfos)..where((tbl) => tbl.uid.equals(uid))).watchSingle();
  }

}