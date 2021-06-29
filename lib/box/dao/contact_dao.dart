import 'package:deliver_flutter/box/contact.dart';
import 'package:hive/hive.dart';

abstract class ContactDao {
  Future<Contact> get(String uid);
}

class ContactDaoImpl implements ContactDao {
  Future<Contact> get(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  static String _key() => "last-activity";

  static Future<Box<Contact>> _open() => Hive.openBox<Contact>(_key());
}
