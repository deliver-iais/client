import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'id_uid.g.dart';

@HiveType(typeId: ID_UID_TRACK_ID)
class IdUid {
  // DbId
  @HiveField(0)
  String id;

  @HiveField(1)
  String uid;

  @HiveField(3)
  int lastUpdate;

  IdUid({this.id, this.uid, this.lastUpdate});
}
