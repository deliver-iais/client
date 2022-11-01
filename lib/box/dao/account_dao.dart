import 'package:deliver/box/account.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class AccountDao extends DBManager {
  Future<void> updateAccount({
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

  Future<Account?> getAccount();

  Stream<Account?> getAccountStream();
}

class AccountDaoImpl extends AccountDao {
  static String _key() => "account";

  Future<BoxPlus<Account>> _open() {
    super.open(_key(), ACCOUNT_TABLE_NAME);
    return gen(Hive.openBox<Account>(_key()));
  }

  @override
  Future<Account?> getAccount() async {
    final box = await _open();
    return box.get(_key());
  }

  @override
  Stream<Account?> getAccountStream() async* {
    final box = await _open();
    yield box.get(_key());

    yield* box.watch().map((event) => box.get(_key()));
  }

  @override
  Future<void> updateAccount({
    int? countryCode,
    int? nationalNumber,
    String? username,
    String? firstname,
    String? lastname,
    bool? emailVerified,
    bool? passwordProtected,
    String? email,
    String? description,
  }) async {
    final box = await _open();

    final account = box.get(_key()) ?? Account();
    return box.put(
      _key(),
      account.copyWith(
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
