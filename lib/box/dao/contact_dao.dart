import 'package:deliver/box/contact.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract class ContactDao {
  Future<Contact?> get(PhoneNumber phoneNumber);

  Future<Contact?> getByUid(Uid uid);

  Future<void> save({
    required PhoneNumber phoneNumber,
    String? firstName,
    String? lastName,
    String? uid,
    String? description,
    int? syncHash,
    int? updateTime,
  });

  Future<List<Contact>> getAllContacts();

  Future<List<Contact>> getAllMessengerContacts();

  Stream<List<Contact>> watchAllMessengerContacts();

  Future<List<Contact>> getNotMessengerContacts();

  Stream<List<Contact>> watchNotMessengerContacts();

  Stream<List<Contact>> watchAll();
}

