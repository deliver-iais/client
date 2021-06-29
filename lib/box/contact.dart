import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: CONTACT_TRACK_ID)
class Contact {
  // DbId
  @HiveField(0)
  String phoneNumber;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String firstName;

  @HiveField(3)
  String lastName;

  Contact(
      {this.uid,
      this.firstName,
      this.lastName,
      this.phoneNumber});
}
