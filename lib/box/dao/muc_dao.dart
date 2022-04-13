import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/muc.dart';
import 'package:hive/hive.dart';

abstract class MucDao {
  Future<Muc?> get(String uid);

  Stream<Muc?> watch(String uid);

  Future<void> save(Muc muc);

  Future<void> update(Muc muc);

  Future<void> delete(String uid);

  Future<Member?> getMember(String mucUid, String memberUid);

  Future<List<Member?>> getAllMembers(String mucUid);

  Stream<List<Member?>> watchAllMembers(String mucUid);

  Future<void> saveMember(Member member);

  Future<void> deleteMember(Member member);

  Future<void> deleteAllMembers(String mucUid);
}

class MucDaoImpl implements MucDao {
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
  Future<void> update(Muc muc) async {
    final box = await _openMuc();

    final m = box.get(muc.uid);
    return box.put(muc.uid, m!.copy(muc));
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
  Future<Member?> getMember(String memberUid, String mucUid) async {
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

  static Future<BoxPlus<Muc>> _openMuc() {
    BoxInfo.addBox(_keyMuc());
    return gen(Hive.openBox<Muc>(_keyMuc()));
  }

  static String _keyMembers(String uid) => "member-$uid";

  static Future<BoxPlus<Member>> _openMembers(String uid) {
    BoxInfo.addBox(_keyMembers(uid.replaceAll(":", "-")));
    return gen(Hive.openBox<Member>(_keyMembers(uid.replaceAll(":", "-"))));
  }
}
