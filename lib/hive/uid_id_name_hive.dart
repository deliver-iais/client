import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'uid_id_name_hive.g.dart';

@HiveType(typeId: UID_ID_NAME_TRACK_ID)
class UidIdNameHive {
  // DbId
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? id;

  @HiveField(2)
  String? name;

  @HiveField(4)
  int? lastUpdate;

  @HiveField(5)
  String? realName;

  UidIdNameHive({
    required this.uid,
    this.id,
    this.name,
    this.lastUpdate,
    this.realName,
  });

  UidIdNameHive copyWith({
    required String uid,
    String? id,
    String? name,
    int? lastUpdate,
    String? realName,
  }) =>
      UidIdNameHive(
        uid: uid,
        id: id ?? this.id,
        name: name ?? this.name,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        realName: realName ?? this.realName,
      );

  UidIdName fromHive() => UidIdName(
        uid: uid.asUid(),
        name: name,
        id: id,
        realName: realName,
        lastUpdateTime: lastUpdate ?? 0,
      );
}

extension UidIdNameHiveMapper on UidIdName {
  UidIdNameHive toHive() => UidIdNameHive(
        uid: uid.asString(),
        name: name,
        id: id,
        realName: realName,
        lastUpdate: lastUpdateTime,
      );
}
