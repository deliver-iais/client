import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'uid_id_name.g.dart';

@HiveType(typeId: UID_ID_NAME_TRACK_ID)
class UidIdName {
  // DbId
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? id;

  @HiveField(2)
  String? name;

  @HiveField(4)
  int? lastUpdate;

  UidIdName({required this.uid, this.id, this.name, this.lastUpdate});

  UidIdName copyWith(
          {required String uid, String? id, String? name, int? lastUpdate}) =>
      UidIdName(
        uid: uid,
        id: id ?? this.id,
        name: name ?? this.name,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}
