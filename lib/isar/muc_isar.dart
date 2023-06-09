import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'muc_isar.g.dart';

@collection
class MucIsar {
  Id get dbId => fastHash(uid);

  String uid;

  String id;

  String name;

  String token;

  String info;

  List<int>? pinMessagesIdList;

  int population;

  int lastCanceledPinMessageId;

  @enumerated
  MucType mucType;

  @enumerated
  MucRole currentUserRole;

  MucIsar({
    required this.uid,
    this.name = "",
    this.id = "",
    this.token = "",
    this.info = "",
    this.pinMessagesIdList,
    this.population = 0,
    this.lastCanceledPinMessageId = 0,
    this.mucType = MucType.Public,
    this.currentUserRole = MucRole.NONE,
  });

  Muc fromIsar() => Muc(
        uid: uid.asUid(),
        name: name,
        id: id,
        population: population,
        lastCanceledPinMessageId: lastCanceledPinMessageId,
        mucType: mucType,
        info: info,
        currentUserRole: currentUserRole,
        token: token,
        pinMessagesIdList: pinMessagesIdList ?? [],
      );
}

extension MucIsarMapper on Muc {
  MucIsar toIsar() => MucIsar(
        uid: uid.asString(),
        name: name,
        id: id,
        currentUserRole: currentUserRole,
        population: population,
        lastCanceledPinMessageId: lastCanceledPinMessageId,
        mucType: mucType,
        info: info,
        token: token,
        pinMessagesIdList: pinMessagesIdList,
      );
}
