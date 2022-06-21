import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/adapters.dart';

part 'account.g.dart';

@HiveType(typeId: ACCOUNT_TRACK_ID)
class Account {
  @HiveField(0)
  int? countryCode;

  @HiveField(1)
  int? nationalNumber;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String? firstname;

  @HiveField(4)
  String? lastname;

  @HiveField(5)
  bool? passwordProtected;

  @HiveField(6)
  String? email;

  @HiveField(7)
  String? description;

  @HiveField(8)
  bool? emailVerified;

  Account({
    this.countryCode,
    this.nationalNumber,
    this.username,
    this.firstname,
    this.lastname,
    this.passwordProtected,
    this.email,
    this.description,
    this.emailVerified,
  });

  Account copyWith({
    int? countryCode,
    int? nationalNumber,
    String? username,
    String? firstname,
    String? lastname,
    bool? passwordProtected,
    bool? emailVerified,
    String? email,
    String? description,
  }) =>
      Account(
        countryCode: countryCode ?? this.countryCode,
        nationalNumber: nationalNumber ?? this.nationalNumber,
        username: username ?? this.username,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        email: email ?? this.email,
        emailVerified: emailVerified ?? this.emailVerified,
        passwordProtected: passwordProtected ?? this.passwordProtected,
        description: description ?? this.description,
      );
}
