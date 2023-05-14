import 'package:deliver/box/is_verified.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class IsVerifiedDao {
  Future<IsVerified?> getIsVerified(Uid uid);

  Future<void> update(Uid uid, int expireTime);
}
