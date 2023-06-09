import 'package:deliver/box/contact.dart';
import 'package:deliver/isar/helpers.dart';
import 'package:deliver/shared/extensions/phone_number_extention.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:isar/isar.dart';

part 'contact_isar.g.dart';

@collection
class ContactIsar {
  Id get dbId => fastHash(phoneNumber);

  final String? uid;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String description;
  final int updateTime;
  final int syncHash;

  ContactIsar({
    this.uid,
    required this.phoneNumber,
    this.firstName = "",
    this.lastName = "",
    this.description = "",
    this.updateTime = 0,
    this.syncHash = 0,
  });

  Contact fromIsar() => Contact(
        uid: uid?.asUid(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: PhoneNumber.fromJson(phoneNumber),
        description: description,
        updateTime: updateTime,
        syncHash: syncHash,
      );
}

extension ContactIsarMapper on Contact {
  ContactIsar toIsar() => ContactIsar(
        uid: uid?.asString(),
        firstName: firstName,
        phoneNumber: phoneNumber.asString(),
        lastName: lastName,
        description: description,
        updateTime: updateTime,
        syncHash: syncHash,
      );
}
