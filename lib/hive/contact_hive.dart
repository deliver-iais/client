import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:hive/hive.dart';

part 'contact_hive.g.dart';

@HiveType(typeId: CONTACT_TRACK_ID)
class ContactHive {
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

  ContactHive({
    required this.countryCode,
    required this.nationalNumber,
    this.uid,
    this.firstName,
    this.lastName,
    this.description,
    this.updateTime,
    this.syncHash,
  });

  ContactHive copyWith({
    required int nationalNumber,
    String? uid,
    String? lastName,
    String? firstName,
    required int countryCode,
    String? description,
    int? updateTime,
    int? syncHash,
  }) =>
      ContactHive(
        countryCode: countryCode,
        nationalNumber: nationalNumber,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        uid: uid ?? this.uid,
        description: description ?? this.description,
        updateTime: updateTime ?? this.updateTime,
        syncHash: syncHash ?? this.syncHash,
      );


  Contact fromHive() => Contact(
        uid: uid?.asUid(),
        firstName: firstName ?? "",
        lastName: lastName ?? "",
        description: description ?? "",
        updateTime: updateTime ?? 0,
        syncHash: syncHash ?? 0,
        phoneNumber: PhoneNumber()
          ..nationalNumber = Int64(nationalNumber)
          ..countryCode = countryCode,
      );
}

extension ContactHiveMapper on Contact {
  ContactHive toHive() => ContactHive(
        uid: uid?.asString(),
        firstName: firstName,
        lastName: lastName,
        description: description,
        updateTime: updateTime,
        syncHash: syncHash,
        countryCode: phoneNumber.countryCode,
        nationalNumber: phoneNumber.nationalNumber.toInt(),
      );
}
