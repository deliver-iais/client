import 'package:deliver_flutter/box/contact.dart';
import 'package:hive/hive.dart';

abstract class ContactDao {
  Future<Contact> get(String phoneNumber);

  Future<Contact> getByUid(String uid);

  Future<List<Contact>> getAll();

  Stream<List<Contact>> watchAll();

  Future<void> save(Contact contact);
}

class ContactDaoImpl implements ContactDao {
  Future<Contact> get(String phoneNumber) async {
    var box = await _open();

    return box.values.firstWhere(
        (element) => element.phoneNumber == phoneNumber,
        orElse: () => null);
  }

  Future<Contact> getByUid(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  Future<List<Contact>> getAll() async {
    var box = await _open();

    return box.values.toList();
  }

  Stream<List<Contact>> watchAll() async* {
    var box = await _open();

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  Future<void> save(Contact contact) async {
    var box = await _open();

    return box.put(contact.uid, contact);
  }

  static String _key() => "contact";

  static Future<Box<Contact>> _open() => Hive.openBox<Contact>(_key());
}
