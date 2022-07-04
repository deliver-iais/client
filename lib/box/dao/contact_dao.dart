import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive/hive.dart';

abstract class ContactDao {
  Future<Contact?> get(int countryCode, int nationalNumber);

  Future<Contact?> getByUid(String uid);

  Future<List<Contact>> getAll();

  Future<List<Contact>?> getAllUserASContact();

  Stream<List<Contact>> watchAll();

  Future<void> save({
    required int countryCode,
    required int nationalNumber,
    String? firstName,
    String? lastName,
    String? uid,
    String? description,
    int? syncHash,
    int? updateTime,
  });

  Future<List<Contact>?> getNotMessengerContact();

  Stream<List<Contact>?> getNotMessengerContactAsStream();
}

class ContactDaoImpl implements ContactDao {
  @override
  Future<Contact?> get(int countryCode, int nationalNumber) async {
    final box = await _open();

    try {
      box.values.firstWhere(
        (element) =>
            element.countryCode == countryCode &&
            element.nationalNumber == nationalNumber,
      );
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<Contact?> getByUid(String uid) async {
    try {
      final box = await _open();

      return box.values
          .where((element) => element.uid != null && element.uid == uid)
          .first;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Contact>> getAll() async {
    final box = await _open();

    return box.values.toList();
  }

  @override
  Future<List<Contact>> getAllUserASContact() async {
    final box = await _open();
    return box.values.where((element) => element.uid != null).toList();
  }

  @override
  Stream<List<Contact>> watchAll() async* {
    final box = await _open();

    yield box.values.where((element) => element.uid != null).toList();

    yield* box.watch().map(
          (event) =>
              box.values.where((element) => element.uid != null).toList(),
        );
  }

  static String _key() => "contact";

  static Future<BoxPlus<Contact>> _open() {
    BoxInfo.addBox(_key());
    return gen(Hive.openBox<Contact>(_key()));
  }

  @override
  Future<void> save({
    required int countryCode,
    required int nationalNumber,
    String? firstName,
    String? lastName,
    String? uid,
    String? description,
    int? syncHash,
    int? updateTime,
  }) async {
    final box = await _open();

    final clone = box.get(nationalNumber.toString()) ??
        Contact(countryCode: countryCode, nationalNumber: nationalNumber);

    final c = clone.copyWith(
      nationalNumber: nationalNumber,
      countryCode: countryCode,
      firstName: firstName,
      lastName: lastName,
      description: description,
      updateTime: updateTime,
      uid: uid,
      syncHash: syncHash,
    );
    if (c != clone) return box.put(nationalNumber.toString(), c);
  }

  @override
  Future<List<Contact>?> getNotMessengerContact() async {
    try {
      final box = await _open();
      return box.values.where((element) => element.uid == null).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Stream<List<Contact>?> getNotMessengerContactAsStream() async* {
    final box = await _open();

    yield box.values.where((element) => element.uid == null).toList();

    yield* box.watch().map(
          (event) =>
              box.values.where((element) => element.uid == null).toList(),
        );
  }
}
