
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';


abstract class UidIdNameDao {
  Future<UidIdName?> getByUid(Uid  uid);

  Stream<String?> watchIdByUid(Uid uid);

  Future<String?> getUidById(String id);

  Future<void> update(Uid uid, {String? id, String? name,String? realName});

  Future<List<UidIdName>> search(String term);
}

