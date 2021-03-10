import 'package:deliver_flutter/db/Contacts.dart';
import 'package:moor/moor.dart';
import '../database.dart';

part 'ContactDao.g.dart';

@UseDao(tables: [Contacts])
class ContactDao extends DatabaseAccessor<Database> with _$ContactDaoMixin {
  final Database database;

  ContactDao(this.database) : super(database);

  Future insertContact(ContactsCompanion contact) =>
      into(contacts).insertOnConflictUpdate(contact);

  Future deleteAvatar(Contact contact) => delete(contacts).delete(contact);

  Future<Contact> getContactByUid(String uid) {
    return (select(contacts)..where((tbl) => tbl.uid.equals(uid))).getSingle();
  }

  Future<Contact> getContact(String phoneNumber) {
    return (select(contacts)
          ..where((tbl) => tbl.phoneNumber.equals(phoneNumber)))
        .getSingle();
  }

  Stream<List<Contact>> getAllContacts() => select(contacts).watch();

  Future<List<Contact>> getContactByName(String text) {
    return (select(contacts)
          ..where((tbl) =>
              tbl.lastName.contains(text) |
              tbl.firstName.contains(text) |
              tbl.username.contains(text)))
        .get();
  }

  Future<List<Contact>> getAllUser() {
    return (select(contacts)..where((tbl) => isNotNull(tbl.uid))).get();
  }

  Future<Contact> searchByUserName(String username) {
    return (select(contacts)..where((tbl) => tbl.username.equals(username)))
        .getSingle();
  }
}
