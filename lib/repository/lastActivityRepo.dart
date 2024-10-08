// TODO(any): change file name
// ignore_for_file: file_names

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class LastActivityRepo {
  final _lastActivityDao = GetIt.I.get<LastActivityDao>();
  final _logger = GetIt.I.get<Logger>();

  final _sdp = GetIt.I.get<ServicesDiscoveryRepo>();

  Future<void> updateLastActivity(Uid userUid) async {
    final la = await _lastActivityDao.get(userUid.asString());
    if (la != null &&
        clock.now().millisecondsSinceEpoch - la.lastUpdate < 10 * 60) {
      return;
    } else {
      return _getLastActivityTime(userUid);
    }
  }

  Future<LastActivity?> get(String uid) => _lastActivityDao.get(uid);

  Stream<LastActivity?> watch(String uid) => _lastActivityDao.watch(uid);

  Future<void> _getLastActivityTime(Uid currentUserUid) async {
    final lastActivityTime = await _sdp.queryServiceClient
        .getLastActivity(GetLastActivityReq()..uid = currentUserUid);

    _logger.v(lastActivityTime.toString());

    return _lastActivityDao.save(
      LastActivity(
        uid: currentUserUid.asString(),
        time: lastActivityTime.lastActivityTime.toInt(),
        lastUpdate: clock.now().millisecondsSinceEpoch,
      ),
    );
  }
}
