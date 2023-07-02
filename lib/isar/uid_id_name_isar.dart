import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'uid_id_name_isar.g.dart';

@collection
class UidIdNameIsar {
  Id get dbId => fastHash(uid);

  String uid;

  String name;

  String id;

  String realName;

  int lastUpdateTime;

  UidIdNameIsar({
    required this.uid,
    this.name = "",
    this.id = "",
    this.lastUpdateTime = 0,
    this.realName = "",
  });

  UidIdName fromIsar() => UidIdName(
        uid: uid.asUid(),
        name: name,
        id: id,
        realName: realName,
        lastUpdateTime: lastUpdateTime,
      );
}

extension UidIdNameHiveMapper on UidIdName {
  UidIdNameIsar toIsar() => UidIdNameIsar(
        uid: uid.asString(),
        name: name ?? '',
        id: id ?? '',
        realName: realName ?? '',
        lastUpdateTime: lastUpdateTime,
      );
}
