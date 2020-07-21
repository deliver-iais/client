import 'package:deliver_flutter/db/Contacts.dart';
import 'package:moor/moor.dart';
import '../database.dart';

part 'ContactDao.g.dart';

@UseDao(tables: [Contacts])
class ContactDao extends DatabaseAccessor<Database> with _$ContactDaoMixin {
  final Database database;

  ContactDao(this.database) : super(database);

  getContact(String uid) {
    return (select(contacts)..where((tbl) => tbl.uid.equals(uid))).get();
  }

  Stream getAllContacts() => select(contacts).watch();
}
