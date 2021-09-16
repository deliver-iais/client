import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: CONTACT_TRACK_ID)
class Contact {
  // DbId
  @HiveField(0)
  String countryCode;

  @HiveField(1)
  String nationalNumber;

  @HiveField(2)
  String uid;

  @HiveField(3)
  String firstName;

  @HiveField(4)
  String lastName;

  Contact({
    this.countryCode,
    this.nationalNumber,
    this.uid,
    this.firstName,
    this.lastName,
  });
}
