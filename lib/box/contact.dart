import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: CONTACT_TRACK_ID)
class Contact {
  // DbId
  @HiveField(0)
  int countryCode;

  @HiveField(1)
  int nationalNumber;

  @HiveField(2)
  String uid;

  @HiveField(3)
  String? firstName;

  @HiveField(4)
  String? lastName;

  @HiveField(5)
  String? description;

  Contact({
    required this.countryCode,
    required this.nationalNumber,
    required this.uid,
    this.firstName,
    this.lastName,
    this.description,
  });

  bool isUsersContact() => countryCode == 0;
}
