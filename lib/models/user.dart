import 'package:deliver/box/contact.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

class User {
  PhoneNumber? phoneNumber;
  String firstname;
  String lastname;
  String? id;
  Uid? uid;

  User({
    this.phoneNumber,
    required this.firstname,
    this.lastname = "",
    this.id,
    this.uid,
  });
}

extension ContactMapper on User {
  Contact toContact() => Contact(
        firstName: firstname,
        lastName: lastname,
        uid: uid,
        phoneNumber: phoneNumber!,
      );
}
