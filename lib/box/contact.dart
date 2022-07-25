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
  String? uid;

  @HiveField(3)
  String? firstName;

  @HiveField(4)
  String? lastName;

  @HiveField(5)
  String? description;

  @HiveField(6)
  int? updateTime;

  @HiveField(7)
  int? syncHash;

  Contact({
    required this.countryCode,
    required this.nationalNumber,
    this.uid,
    this.firstName,
    this.lastName,
    this.description,
    this.updateTime,
    this.syncHash,
  });

  Contact copyWith({
    required int nationalNumber,
    String? uid,
    String? lastName,
    String? firstName,
    required int countryCode,
    String? description,
    int? updateTime,
    int? syncHash,
  }) =>
      Contact(
          countryCode: countryCode,
          nationalNumber: nationalNumber,
          lastName: lastName ?? this.lastName,
          firstName: firstName ?? this.firstName,
          uid: uid ?? this.uid,
          description: description ?? this.description,
          updateTime: updateTime ?? this.updateTime,
          syncHash: syncHash ?? this.syncHash,);

  bool isUsersContact() => countryCode == 0;
}
