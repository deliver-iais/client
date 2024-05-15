import 'package:deliver/box/broadcast_member.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/hive/member_hive.dart';
import 'package:deliver/hive/muc_hive.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MucDaoImpl extends MucDao {
  @override
  Future<void> delete(Uid uid) async {
    final box = await _openMuc();

    return box.delete(uid.asString());
  }

  @override
  Future<Muc?> get(Uid uid) async {
    final box = await _openMuc();

    return box.get(uid.asString())?.fromHive();
  }

  @override
  Stream<Muc?> watch(Uid uid) async* {
    final box = await _openMuc();

    yield box.get(uid.asString())?.fromHive();

    yield* box
        .watch(key: uid.asString())
        .map((event) => box.get(uid.asString())?.fromHive());
  }

  @override
  Future<void> deleteAllMembers(Uid mucUid) async {
    final box = await _openMembers(mucUid.asString());

    await box.clear();
  }

  @override
  Future<void> deleteMember(Member member) async {
    final box = await _openMembers(member.mucUid.asString());

    return box.delete(member.memberUid.asString());
  }

  @override
  Future<List<Member>> getAllMembers(Uid mucUid) async {
    final box = await _openMembers(mucUid.asString());

    return box.values.map((e) => e.fromHive()).toList();
  }

  @override
  Future<List<BroadcastMember?>> getAllBroadcastSmsMembers(Uid mucUid) async {
    return [];
  }

  @override
  Future<void> saveMember(Member member) async {
    final box = await _openMembers(member.mucUid.asString());

    return box.put(member.memberUid.asString(), member.toHive());
  }

  @override
  Stream<List<Member>> watchAllMembers(Uid mucUid) async* {
    final box = await _openMembers(mucUid.asString());

    yield box.values.map((e) => e.fromHive()).toList();

    yield* box
        .watch()
        .map((event) => box.values.map((e) => e.fromHive()).toList());
  }

  static String _keyMuc() => "muc";

  Future<BoxPlus<MucHive>> _openMuc() {
    DBManager.open(_keyMuc(), TableInfo.MUC_TABLE_NAME);
    return gen(Hive.openBox<MucHive>(_keyMuc()));
  }

  static String _keyMembers(String uid) =>
      "member-${uid.convertUidStringToDaoKey()}";

  Future<BoxPlus<MemberHive>> _openMembers(String uid) {
    DBManager.open(_keyMembers(uid), TableInfo.MEMBER_TABLE_NAME);
    return gen(Hive.openBox<MemberHive>(_keyMembers(uid)));
  }

  @override
  Future<void> updateMuc({
    required Uid uid,
    String? info,
    List<int>? pinMessagesIdList,
    int? lastCanceledPinMessageId,
    int? population,
    String? id,
    bool? synced,
    String? token,
    MucType? mucType,
    String? name,
    MucRole? currentUserRole,
  }) async {
    final box = await _openMuc();
    final muc = box.get(uid.asString()) ?? MucHive(uid: uid.asString());
    box
        .put(
          uid.asString(),
          muc.copyWith(
            uid: uid.asString(),
            info: info,
            id: id,
            synced: synced,
            currentUserRole: currentUserRole,
            population: population,
            pinMessagesIdList: pinMessagesIdList,
            lastCanceledPinMessageId: lastCanceledPinMessageId,
            token: token,
            name: name,
            mucType: mucType,
          ),
        )
        .ignore();
  }

  @override
  Future<int> getBroadCastAllMemberCount(Uid mucUid) async {
    final box = await _openMembers(mucUid.asString());
    return box.keys.length;
  }

  @override
  Future<void> saveSmsBroadcastContact(
    BroadcastMember broadcastMember,
    Uid uid,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<Member>> getMembersFirstPage(Uid mucUid, int pageSize) async {
    final box = await _openMembers(mucUid.asString());

    return box.values.take(pageSize).map((e) => e.fromHive()).toList();
  }

  @override
  Future<List<Muc>> getNitSyncedLocalMuc() async {
    try {
      final box = await _openMuc();
      return box.values
          .where((element) => !element.synced)
          .map((e) => e.fromHive())
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Uid?> getLocalMucOwner(Uid uid) async {
    try {
      final box = await _openMembers(uid.asString());
      return box.values
          .where((element) => element.role == MucRole.OWNER)
          .first
          .memberUid
          .asUid();
    } catch (_) {}
    return null;
  }
}
