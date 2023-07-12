import 'package:deliver/box/broadcast_member.dart';
import 'package:deliver/box/broadcast_member_type.dart';
import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/isar/broadcast_member_isar.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/isar/member_isar.dart';
import 'package:deliver/isar/muc_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class MucDaoImpl extends MucDao {
  @override
  Future<void> delete(Uid uid) async {
    final box = await _openIsar();
    box.writeTxnSync(() => box.mucIsars.deleteSync(fastHash(uid.asString())));
  }

  @override
  Future<void> deleteAllMembers(Uid mucUid) async {
    final box = await _openIsar();
    if (mucUid.isBroadcast()) {
      final query = box.broadcastMemberIsars
          .filter()
          .broadcastUidEqualTo(mucUid.asString())
          .and()
          .typeEqualTo(BroadCastMemberType.MESSAGE)
          .build();
      box.writeTxnSync(() => query.deleteAllSync());
    } else {
      final query =
          box.memberIsars.filter().mucUidEqualTo(mucUid.asString()).build();
      box.writeTxnSync(() => query.deleteAllSync());
    }
  }

  @override
  Future<void> deleteMember(Member member) async {
    final box = await _openIsar();
    if (member.mucUid.isBroadcast()) {
      final query = box.broadcastMemberIsars
          .filter()
          .broadcastUidEqualTo(member.mucUid.asString())
          .and()
          .memberUidEqualTo(member.memberUid.asString())
          .build();
      box.writeTxnSync(() => query.deleteAllSync());
    } else {
      box.writeTxnSync(
        () => box.memberIsars.deleteSync(
          fastHash("${member.mucUid.asString()}${member.memberUid.asString()}"),
        ),
      );
    }
  }

  @override
  Future<Muc?> get(Uid uid) async {
    final box = await _openIsar();
    return box.mucIsars.getSync(fastHash(uid.asString()))?.fromIsar();
  }

  @override
  Future<List<BroadcastMember?>> getAllBroadcastSmsMembers(Uid mucUid) async {
    final box = await _openIsar();
    return (box.broadcastMemberIsars
            .filter()
            .broadcastUidEqualTo(
              mucUid.asString(),
            )
            .and()
            .typeEqualTo(BroadCastMemberType.SMS)
            .findAllSync())
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<List<Member>> getAllMembers(Uid mucUid) async {
    final box = await _openIsar();
    if (mucUid.isBroadcast()) {
      return (box.broadcastMemberIsars
              .filter()
              .broadcastUidEqualTo(
                mucUid.asString(),
              )
              .and()
              .typeEqualTo(BroadCastMemberType.MESSAGE)
              .findAllSync())
          .map((e) => Member(mucUid: mucUid, memberUid: e.memberUid!.asUid()))
          .toList();
    } else {
      return box.memberIsars
          .filter()
          .mucUidEqualTo(mucUid.asString())
          .findAllSync()
          .map((e) => e.fromIsar())
          .toList();
    }
  }

  @override
  Future<int> getBroadCastAllMemberCount(Uid mucUid) async {
    final box = await _openIsar();
    return box.broadcastMemberIsars
        .filter()
        .broadcastUidEqualTo(mucUid.asString())
        .findAllSync()
        .length;
  }

  @override
  Future<void> saveMember(Member member) async {
    final box = await _openIsar();
    if (member.mucUid.isBroadcast()) {
      box.writeTxnSync(
        () => box.broadcastMemberIsars.putSync(
          BroadcastMemberIsar(
            broadcastUid: member.mucUid.asString(),
            memberUid: member.memberUid.asString(),
          ),
        ),
      );
    } else {
      box.writeTxnSync(() => box.memberIsars.putSync(member.toIsar()));
    }
  }

  @override
  Future<void> saveSmsBroadcastContact(
    BroadcastMember broadcastMember,
    Uid uid,
  ) async {
    final box = await _openIsar();
    box.writeTxnSync(
      () => box.broadcastMemberIsars.putSync(broadcastMember.toIsar()),
    );
  }

  @override
  Future<void> updateMuc({
    required Uid uid,
    String? info,
    List<int>? pinMessagesIdList,
    int? lastCanceledPinMessageId,
    int? population,
    String? id,
    String? token,
    String? name,
    MucType? mucType,
    MucRole? currentUserRole,
  }) async {
    final box = await _openIsar();
    box.writeTxnSync(() {
      final muc =
          box.mucIsars.filter().uidEqualTo(uid.asString()).findFirstSync() ??
              MucIsar(uid: uid.asString());
      box.mucIsars.putSync(
        MucIsar(
          uid: uid.asString(),
          population: population ?? muc.population,
          token: token ?? muc.token,
          mucType: mucType ?? muc.mucType,
          name: name ?? muc.name,
          id: id ?? muc.id,
          info: info ?? muc.info,
          currentUserRole: currentUserRole ?? muc.currentUserRole,
          lastCanceledPinMessageId:
              lastCanceledPinMessageId ?? muc.lastCanceledPinMessageId,
          pinMessagesIdList: pinMessagesIdList ?? muc.pinMessagesIdList,
        ),
      );
    });
  }

  @override
  Stream<Muc?> watch(Uid uid) async* {
    final box = await _openIsar();

    final query = box.mucIsars.filter().uidEqualTo(uid.asString()).build();

    yield query.findFirstSync()?.fromIsar() ?? Muc(uid: uid);

    yield* query.watch().map(
          (event) =>
              event.map((e) => e.fromIsar()).firstOrNull ?? Muc(uid: uid),
        );
  }

  @override
  Stream<List<Member>> watchAllMembers(Uid mucUid) async* {
    final box = await _openIsar();

    if (mucUid.isBroadcast()) {
      final query = box.broadcastMemberIsars
          .filter()
          .broadcastUidEqualTo(mucUid.asString())
          .typeEqualTo(BroadCastMemberType.MESSAGE)
          .build();

      yield query
          .findAllSync()
          .map((e) => Member(mucUid: mucUid, memberUid: e.memberUid!.asUid()))
          .toList();

      yield* query.watch().map(
            (event) => event
                .map(
                  (e) =>
                      Member(mucUid: mucUid, memberUid: e.memberUid!.asUid()),
                )
                .toList(),
          );
    } else {
      final query =
          box.memberIsars.filter().mucUidEqualTo(mucUid.asString()).build();

      yield query.findAllSync().map((e) => e.fromIsar()).toList();

      yield* query
          .watch()
          .map((event) => event.map((e) => e.fromIsar()).toList());
    }
  }

  Future<Isar> _openIsar() => IsarManager.open();

  @override
  Future<List<Member>> getMembersFirstPage(Uid mucUid, int pageSize) async {
    final box = await _openIsar();
    if (mucUid.isBroadcast()) {
      return (box.broadcastMemberIsars
              .filter()
              .broadcastUidEqualTo(
                mucUid.asString(),
              )
              .and()
              .typeEqualTo(BroadCastMemberType.MESSAGE)
              .limit(pageSize)
              .findAllSync())
          .map((e) => Member(mucUid: mucUid, memberUid: e.memberUid!.asUid()))
          .toList();
    } else {
      return box.memberIsars
          .filter()
          .mucUidEqualTo(mucUid.asString())
          .limit(pageSize)
          .findAllSync()
          .map((e) => e.fromIsar())
          .toList();
    }
  }
}
