import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:hive/hive.dart';

abstract class ContactDao {
  Future<Contact?> get(String countryCode, String nationalNumber);

  Future<Contact?> getByUid(String uid);

  Future<List<Contact>> getAll();

  Stream<List<Contact>> watchAll();

  Future<void> save(Contact contact);
}

class ContactDaoImpl implements ContactDao {
  @override
  Future<Contact?> get(String countryCode, String nationalNumber) async {
    var box = await _open();

    try {
      box.values.firstWhere((element) =>
          element.countryCode == countryCode &&
          element.nationalNumber == nationalNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Contact?> getByUid(String uid) async {
    var box = await _open();

    return box.get(uid);
  }

  @override
  Future<List<Contact>> getAll() async {
    var box = await _open();

    return box.values.toList();
  }

  @override
  Stream<List<Contact>> watchAll() async* {
    var box = await _open();

    yield box.values.toList();

    yield* box.watch().map((event) => box.values.toList());
  }

  @override
  Future<void> save(Contact contact) async {
    var box = await _open();

    return box.put(contact.uid, contact);
  }

  static String _key() => "contact";

  static Future<Box<Contact>> _open() {
    BoxInfo.addBox(_key());
    return Hive.openBox<Contact>(_key());
  }
}
