import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'uid_id_name.g.dart';

@HiveType(typeId: UID_ID_NAME_TRACK_ID)
class UidIdName {
  // DbId
  @HiveField(0)
  String uid;

  @HiveField(1)
  String id;

  @HiveField(2)
  String name;

  @HiveField(4)
  int lastUpdate;

  UidIdName({this.uid, this.id, this.name, this.lastUpdate});

  UidIdName copyWith({String uid, String id, String name, int lastUpdate}) =>
      UidIdName(
        uid: uid ?? this.uid,
        id: id ?? this.id,
        name: name ?? this.name,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}
