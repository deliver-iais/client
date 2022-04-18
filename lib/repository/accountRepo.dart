// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/box/dao/accountDao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';

import 'package:get_it/get_it.dart';

import 'package:logger/logger.dart';

class AccountRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _profileServiceClient = GetIt.I.get<UserServiceClient>();
  final _sessionServicesClient = GetIt.I.get<SessionServiceClient>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _accountDao = GetIt.I.get<AccountDao>();
  final _dbManager = GetIt.I.get<DBManager>();

  Future<bool> hasProfile({bool retry = false}) async {
    final account = await _accountDao.getAccount();
    if (account != null && account.firstname != null) {
      return true;
    }
    try {
      final result =
          await _profileServiceClient.getUserProfile(GetUserProfileReq());
      _savePhoneNumber(
        result.profile.phoneNumber.countryCode,
        result.profile.phoneNumber.nationalNumber.toInt(),
      );

      if (result.hasProfile() && result.profile.firstName.isNotEmpty) {
        _saveProfilePrivateData(
          firstName: result.profile.firstName,
          lastName: result.profile.lastName,
          email: result.profile.email,
          twoStepVerificationEnabled: result.profile.isPasswordProtected,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return hasProfile();
      } else {
        return false;
      }
    }
  }

  Future<bool> profileInfoIsSet() async {
    final isSet = await hasProfile(retry: true);
    if (!isSet) {
      return false;
    } else {
      return fetchCurrentUserId();
    }
  }

  Future<bool> fetchCurrentUserId({bool retry = false}) async {
    try {
      final account = await _accountDao.getAccount();
      if (account != null && account.username != null) {
        return true;
      }
      final getIdRequest = await _queryServiceClient
          .getIdByUid(GetIdByUidReq()..uid = _authRepo.currentUserUid);
      if (getIdRequest.id.isNotEmpty) {
        _accountDao.updateAccount(username: getIdRequest.id).ignore();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return fetchCurrentUserId();
      } else {
        return false;
      }
    }
  }

  Future<Account?> getAccount() => _accountDao.getAccount();

  Stream<Account?> getAccountAsStream() => _accountDao.getAccountStream();

  Future<bool> checkUserName(String username) async {
    final checkUsernameRes = await _queryServiceClient
        .idIsAvailable(IdIsAvailableReq()..id = username);
    return checkUsernameRes.isAvailable;
  }

  Future<bool> updateEmail(String email) async {
    final res = await _profileServiceClient
        .updateEmail(UpdateEmailReq()..email = email);
    return res.profile.isEmailVerified;
  }

  Future<bool> setAccountDetails({
    String? username,
    String? firstname,
    String? lastname,
  }) async {
    try {
      if (username != null) {
        await _queryServiceClient.setId(SetIdReq()..id = username);
        _saveProfilePrivateData(username: username);
      }
      if (firstname != null || lastname != null) {
        final saveUserProfileReq = SaveUserProfileReq()
          ..firstName = firstname ?? ""
          ..lastName = lastname ?? "";

        final res =
            await _profileServiceClient.saveUserProfile(saveUserProfileReq);
        _saveProfilePrivateData(
          firstName: res.profile.firstName,
          lastName: res.profile.lastName,
        );
      }
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> updatePassword(
      {String? currentPassword,
      required String newPassword,
      String? passwordHint,}) async {
    final updatePasswordReq = UpdatePasswordReq()
      ..newPassword = newPassword
      ..passwordHint = passwordHint ?? "";
    if (currentPassword != null) {
      updatePasswordReq.currentPassword = currentPassword;
    }
    try {
      await _profileServiceClient.updatePassword(updatePasswordReq);
      await _accountDao.updateAccount(passwordProtected: true);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> disableTwoStepVerification(String password) async {
    try {
      final res = await _profileServiceClient.updatePassword(UpdatePasswordReq()
        ..currentPassword = password
        ..newPassword = "",);
      if (res.profile.isPasswordProtected) {
        return false;
      } else {
        _accountDao.updateAccount(passwordProtected: false).ignore();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void _savePhoneNumber(int countryCode, int nationalNumber) {
    _accountDao.updateAccount(
      countryCode: countryCode.toString(),
      nationalNumber: nationalNumber.toString(),
    );
  }

  void _saveProfilePrivateData({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? twoStepVerificationEnabled,
  }) {
    _accountDao.updateAccount(
      username: username,
      firstname: firstName,
      lastname: lastName,
      email: email,
      passwordProtected: twoStepVerificationEnabled,
    );
  }

  Future<List<Session>> getSessions() async {
    final res = await _sessionServicesClient.getMySessions(GetMySessionsReq());
    return res.sessions;
  }

  Future<void> checkUpdatePlatformSessionInformation() async {
    final pv = await _sharedDao.get(SHARED_DAO_APP_VERSION);
    if (pv != null) {
      // Migrations
      if (shouldRemoveDB(pv)) {
        await _dbManager.deleteDB();
      }

      if (shouldMigrateDB(pv)) {
        await _dbManager.migrate(pv);
      }

      if (shouldUpdateSessionPlatformInformation(pv)) {
        await _sessionServicesClient.updateSessionPlatformInformation(
          UpdateSessionPlatformInformationReq()
            ..platform = await getPlatformPB(),
        );
      }
      // Update version in DB
    } else {
      await _sharedDao.put(SHARED_DAO_APP_VERSION, VERSION);
    }
  }

  bool shouldRemoveDB(String? previousVersion) => previousVersion != VERSION;

  bool shouldMigrateDB(String? previousVersion) => false;

  bool shouldUpdateSessionPlatformInformation(String previousVersion) =>
      previousVersion != VERSION;

  bool shouldShowNewFeaturesDialog(String? previousVersion) =>
      previousVersion != VERSION;

  Future<bool> verifyQrCodeToken(String token) async {
    try {
      await _sessionServicesClient.verifyQrCodeToken(
        VerifyQrCodeTokenReq()
          ..platform = await getPlatformPB()
          ..token = token,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeSession(String session) async {
    try {
      await _sessionServicesClient
          .revokeSession(RevokeSessionReq(sessionIds: [session]));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeAllOtherSession() async {
    try {
      await _sessionServicesClient
          .revokeAllOtherSessions(RevokeAllOtherSessionsReq());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _sessionServicesClient.logoutSession(LogoutSessionReq());
    } catch (_) {}
  }

  Future<String> getName() async {
    final account = await getAccount();

    return buildName(account!.firstname, account.lastname);
  }

  Future<bool> shouldShowNewFeatureDialog() async {
    final pv = await _sharedDao.get(SHARED_DAO_APP_VERSION);
    return shouldShowNewFeaturesDialog(pv);
  }

  Future<bool> isTwoStepVerificationEnabled() async {
    return (await _accountDao.getAccount())!.passwordProtected ?? false;
  }

  Future<bool> changeTwoStepVerificationPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    //todo
    return true;
  }
}
