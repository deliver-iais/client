import 'package:deliver_flutter/box/dao/last_activity_dao.dart';
import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:logger/logger.dart';

class LastActivityRepo {
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _logger = GetIt.I.get<Logger>();

  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  Future<void> updateLastActivity(Uid userUId) async {
    var la = await _lastActivityDao.get(userUId.asString());
    if (la != null &&
        la.time != null &&
        DateTime.now().millisecondsSinceEpoch - la.lastUpdate < 10 * 60) {
      return;
    } else {
      _getLastActivityTime(userUId);
    }
  }

  Future<LastActivity> get(String uid) => _lastActivityDao.get(uid);

  Stream<LastActivity> watch(String uid) => _lastActivityDao.watch(uid);

  Future<void> _getLastActivityTime(Uid currentUserUid) async {
    var lastActivityTime = await _queryServiceClient
        .getLastActivity(GetLastActivityReq()..uid = currentUserUid);
    _logger.v(lastActivityTime.toString());

    if (lastActivityTime != null) {
      _lastActivityDao.save(LastActivity(
          uid: currentUserUid.asString(),
          time: lastActivityTime.lastActivityTime.toInt(),
          lastUpdate: DateTime.now().millisecondsSinceEpoch));
    }
  }
}
