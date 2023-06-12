import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final int? countryCode;

  final int? nationalNumber;

  final String? username;

  final String? firstname;

  final String? lastname;

  final bool? passwordProtected;

  final String? email;

  final String? description;

  final bool? emailVerified;

  const Account({
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

  static const empty = Account();

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

const AccountFromJson = _$AccountFromJson;
const AccountToJson = _$AccountToJson;
