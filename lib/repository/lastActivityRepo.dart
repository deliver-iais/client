
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc.dart';

class LastActivityRepo {
  var _userInfoDao = GetIt.I.get<UserInfoDao>();
  var _accountRepo = GetIt.I.get<AccountRepo>();


  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  updateLastActivity(Uid userUId) async {
    var userInfo = await _userInfoDao.getUserInfo(userUId.asString());
    if (userInfo != null &&
        userInfo.lastActivity != null &&
        DateTime.now().millisecondsSinceEpoch - userInfo.lastTimeActivityUpdated.millisecondsSinceEpoch<
            10 * 60) {
      return;
    } else {
      _getLastActivityTime(userUId);
    }
  }

  void _getLastActivityTime(Uid currentUserUid) async {
    var lastActivityTime = await _queryServiceClient.getLastActivity(
        GetLastActivityReq()..uid = currentUserUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    print("last activity : "+lastActivityTime.lastActivityTime.toString());
    if (lastActivityTime != null) {
      _userInfoDao.upsertUserInfo(UserInfo(
          uid: currentUserUid.asString(),
          lastActivity: DateTime.fromMillisecondsSinceEpoch(
              lastActivityTime.lastActivityTime.toInt()),
          lastTimeActivityUpdated: DateTime.now()));
    }
  }
}
