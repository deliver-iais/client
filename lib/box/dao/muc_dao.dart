import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:hive/hive.dart';

abstract class MucDao extends DBManager {
  Future<Muc?> get(String uid);

  Stream<Muc?> watch(String uid);

  Future<void> save(Muc muc);

  Future<void> delete(String uid);

  Future<void> updateMuc({
    required String uid,
    String? info,
    List<int>? pinMessagesIdList,
    int? lastCanceledPinMessageId,
    int? population,
    String? id,
    String? token,
    String? name,
    MucType? mucType,
  });

  Future<Member?> getMember(String mucUid, String memberUid);

  Future<List<Member?>> getAllMembers(String mucUid);

  Stream<List<Member?>> watchAllMembers(String mucUid);

  Future<void> saveMember(Member member);

  Future<void> deleteMember(Member member);

  Future<void> deleteAllMembers(String mucUid);
}

class MucDaoImpl extends MucDao {
  @override
  Future<void> delete(String uid) async {
    final box = await _openMuc();

    return box.delete(uid);
  }

  @override
  Future<Muc?> get(String uid) async {
    final box = await _openMuc();

    return box.get(uid);
  }

  @override
  Future<void> save(Muc muc) async {
    final box = await _openMuc();

    return box.put(muc.uid, muc);
  }

  @override
  Stream<Muc?> watch(String uid) async* {
    final box = await _openMuc();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  @override
  Future<void> deleteAllMembers(String mucUid) async {
    final box = await _openMembers(mucUid);

    await box.clear();
  }

  @override
  Future<void> deleteMember(Member member) async {
    final box = await _openMembers(member.mucUid);

    return box.delete(member.memberUid);
  }

  @override
  Future<List<Member?>> getAllMembers(String mucUid) async {
    final box = await _openMembers(mucUid);

    return box.values.toList();
  }

  @override
  Future<Member?> getMember(String mucUid, String memberUid) async {
    final box = await _openMembers(mucUid);
    return box.get(memberUid);
  }

  @override
  Future<void> saveMember(Member member) async {
    final box = await _openMembers(member.mucUid);

    return box.put(member.memberUid, member);
  }

  @override
  Stream<List<Member>> watchAllMembers(String mucUid) async* {
    final box = await _openMembers(mucUid);

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  static String _keyMuc() => "muc";

  Future<BoxPlus<Muc>> _openMuc() {
    super.open(_keyMuc(), MUC_TABLE_NAME);
    return gen(Hive.openBox<Muc>(_keyMuc()));
  }

  static String _keyMembers(String uid) => "member-$uid";

  Future<BoxPlus<Member>> _openMembers(String uid) {
    super.open(_keyMembers(uid.replaceAll(":", "-")), MEMBER_TABLE_NAME);
    return gen(Hive.openBox<Member>(_keyMembers(uid.replaceAll(":", "-"))));
  }

  @override
  Future<void> updateMuc({
    required String uid,
    String? info,
    List<int>? pinMessagesIdList,
    int? lastCanceledPinMessageId,
    int? population,
    String? id,
    String? token,
    MucType? mucType,
    String? name,
  }) async {
    final box = await _openMuc();
    final muc = box.get(uid) ?? Muc(uid: uid);
    box
        .put(
          uid,
          muc.copyWith(
            uid: uid,
            info: info,
            id: id,
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
}
