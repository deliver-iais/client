import 'package:deliver/box/account.dart';
import 'package:deliver/services/settings.dart';

abstract class AccountDao {
  void updateAccount({
    int? countryCode,
    int? nationalNumber,
    String? username,
    String? firstname,
    String? lastname,
    bool? emailVerified,
    bool? passwordProtected,
    String? email,
    String? description,
  });

  Account getAccount();

  Stream<Account?> getAccountStream();
}

class AccountDaoImpl extends AccountDao {
  @override
  Account getAccount() {
    return settings.account.value;
  }

  @override
  Stream<Account?> getAccountStream() async* {
    yield* settings.account.stream;
  }

  @override
  void updateAccount({
    int? countryCode,
    int? nationalNumber,
    String? username,
    String? firstname,
    String? lastname,
    bool? emailVerified,
    bool? passwordProtected,
    String? email,
    String? description,
  }) {
    settings.account.set(
      settings.account.value.copyWith(
        nationalNumber: nationalNumber,
        countryCode: countryCode,
        username: username,
        firstname: firstname,
        lastname: lastname,
        email: email,
        emailVerified: emailVerified,
        description: description,
        passwordProtected: passwordProtected,
      ),
    );
  }
}
