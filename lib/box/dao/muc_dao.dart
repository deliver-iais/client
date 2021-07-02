import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:hive/hive.dart';

abstract class MucDao {
  Future<Muc> get(String uid);

  Stream<Muc> watch(String uid);

  Future<void> save(Muc muc);

  Future<void> update(Muc muc);

  Future<void> delete(String uid);

  Future<Member> getMember(String mucUid, String memberUid);

  Future<List<Member>> getAllMembers(String mucUid);

  Stream<List<Member>> watchAllMembers(String mucUid);

  Future<void> saveMember(Member member);

  Future<void> deleteMember(Member member);

  Future<void> deleteAllMembers(String mucUid);
}

class MucDaoImpl implements MucDao {
  Future<void> delete(String uid) async {
    var box = await _openMuc();

    box.delete(uid);
  }

  Future<Muc> get(String uid) async {
    var box = await _openMuc();

    return box.get(uid);
  }

  Future<void> save(Muc muc) async {
    var box = await _openMuc();

    return box.put(muc.uid, muc);
  }

  Future<void> update(Muc muc) async {
    var box = await _openMuc();

    var m = box.get(muc.uid) ?? Muc();

    return box.put(muc.uid, m.copy(muc));
  }

  Stream<Muc> watch(String uid) async* {
    var box = await _openMuc();

    yield box.get(uid);

    yield* box.watch(key: uid).map((event) => box.get(uid));
  }

  Future<void> deleteAllMembers(String mucUid) async {
    var box = await _openMembers(mucUid);

    await box.clear();
  }

  Future<void> deleteMember(Member member) async {
    var box = await _openMembers(member.mucUid);

    return box.get(member.memberUid);
  }

  Future<List<Member>> getAllMembers(String mucUid) async {
    var box = await _openMembers(mucUid);

    return box.values.toList();
  }

  Future<Member> getMember(String mucUid, String memberUid) async {
    var box = await _openMembers(mucUid);

    return box.get(memberUid);
  }

  Future<void> saveMember(Member member) async {
    var box = await _openMembers(member.mucUid);

    box.put(member.memberUid, member);
  }

  Stream<List<Member>> watchAllMembers(String mucUid) async* {
    var box = await _openMembers(mucUid);

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  static String _keyMuc() => "muc";

  static Future<Box<Muc>> _openMuc() => Hive.openBox<Muc>(_keyMuc());

  static String _keyMembers(String uid) => "member-$uid";

  static Future<Box<Member>> _openMembers(String uid) =>
      Hive.openBox<Member>(_keyMembers(uid));
}
