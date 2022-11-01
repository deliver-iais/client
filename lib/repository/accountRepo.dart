// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/box/dao/account_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
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
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  final _authRepo = GetIt.I.get<AuthRepo>();
  final _accountDao = GetIt.I.get<AccountDao>();
  final _dbManager = GetIt.I.get<DBManager>();

  Future<bool> hasProfile({bool retry = false}) async {
    final account = await _accountDao.getAccount();
    if (account != null && account.firstname != null) {
      return true;
    }
    try {
      return getUserProfileFromServer();
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return hasProfile();
      } else {
        return false;
      }
    }
  }

  Future<bool> getUserProfileFromServer() async {
    final result =
        await _sdr.userServiceClient.getUserProfile(GetUserProfileReq());
    _savePhoneNumber(
      result.profile.phoneNumber.countryCode,
      result.profile.phoneNumber.nationalNumber.toInt(),
    );

    if (result.hasProfile() && result.profile.firstName.isNotEmpty) {
      _saveProfilePrivateData(
        firstName: result.profile.firstName,
        lastName: result.profile.lastName,
        email: result.profile.email,
        description: result.profile.description,
        twoStepVerificationEnabled: result.profile.isPasswordProtected,
      );
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchCurrentUserId({
    bool retry = false,
  }) async {
    try {
      final account = await _accountDao.getAccount();
      if ((account == null || account.username == null)) {
        final getIdRequest = await _sdr.queryServiceClient
            .getIdByUid(GetIdByUidReq()..uid = _authRepo.currentUserUid);

        _accountDao.updateAccount(username: getIdRequest.id).ignore();
      }
    } catch (e) {
      _logger.e(e);
      if (retry) {
        unawaited(fetchCurrentUserId());
      }
    }
  }

  Future<Account?> getAccount() => _accountDao.getAccount();

  Stream<Account?> getAccountAsStream() => _accountDao.getAccountStream();

  Future<bool> idIsAvailable(String username) async {
    final checkUsernameRes = await _sdr.queryServiceClient
        .idIsAvailable(IdIsAvailableReq()..id = username);
    return checkUsernameRes.isAvailable;
  }

  Future<bool> updateEmail(String email) async {
    final res = await _sdr.userServiceClient
        .updateEmail(UpdateEmailReq()..email = email);
    if (res.profile.isEmailVerified) {
      _accountDao
          .updateAccount(
            email: res.profile.email,
          )
          .ignore();
      return true;
    }
    return false;
  }

  Future<bool> setAccountDetails({
    String? username,
    String? firstname,
    String? lastname,
    String? description,
  }) async {
    try {
      final account = await getAccount();

      if (firstname == null || firstname.isEmpty) {
        return false;
      }

      try {
        if (username != null &&
            ((account == null ||
                account.username == null ||
                account.username != username))) {
          await _sdr.queryServiceClient.setId(SetIdReq()..id = username);
          _saveProfilePrivateData(username: username);
        }
      } catch (e) {
        _logger.e(e);
      }

      if (lastname != null || description != null) {
        final saveUserProfileReq = SaveUserProfileReq()
          ..firstName = firstname
          ..description = description ?? ""
          ..lastName = lastname ?? "";

        final res =
            await _sdr.userServiceClient.saveUserProfile(saveUserProfileReq);
        _saveProfilePrivateData(
          firstName: res.profile.firstName,
          lastName: res.profile.lastName,
          description: res.profile.description,
        );
      }
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> updatePassword({
    String? currentPassword,
    required String newPassword,
    String? passwordHint,
  }) async {
    final updatePasswordReq = UpdatePasswordReq()
      ..newPassword = newPassword
      ..passwordHint = passwordHint ?? "";
    if (currentPassword != null && currentPassword.isNotEmpty) {
      updatePasswordReq.currentPassword = currentPassword;
    }
    try {
      await _sdr.userServiceClient.updatePassword(updatePasswordReq);
      await _accountDao.updateAccount(passwordProtected: true);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> disableTwoStepVerification(String password) async {
    try {
      final res = await _sdr.userServiceClient.updatePassword(
        UpdatePasswordReq()
          ..currentPassword = password
          ..newPassword = "",
      );
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
      countryCode: countryCode,
      nationalNumber: nationalNumber,
    );
  }

  void _saveProfilePrivateData({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? twoStepVerificationEnabled,
    String? description,
  }) {
    _accountDao.updateAccount(
      username: username,
      firstname: firstName,
      lastname: lastName,
      email: email,
      description: description,
      passwordProtected: twoStepVerificationEnabled,
    );
  }

  Future<List<Session>> getSessions() async {
    final res =
        await _sdr.sessionServiceClient.getMySessions(GetMySessionsReq());
    return res.sessions;
  }

  Future<void> checkUpdatePlatformSessionInformation() async {
    final pDbVersion = await _sharedDao.get(SHARED_DAO_DB_VERSION);
    if (pDbVersion == null ||
        int.parse(pDbVersion) != _dbManager.getDbVersion()) {
      try {
        await _dbManager.migrate(
          deleteSharedDao: false,
          removeOld: true,
        );
        await _sharedDao.putBoolean(SHARED_DAO_ALL_ROOMS_FETCHED, false);
        unawaited(GetIt.I.get<ContactRepo>().getContacts());
      } catch (e) {
        _logger.e(e);
      }
      unawaited(
        _sharedDao.put(
          SHARED_DAO_DB_VERSION,
          _dbManager.getDbVersion().toString(),
        ),
      );
    }
    unawaited(_updateSessionInformationIfNeed());
  }

  Future<void> _updateSessionInformationIfNeed() async {
    final version = await _sharedDao.get(SHARED_DAO_VERSION);
    if (version != null && shouldUpdateSessionPlatformInformation(version)) {
      try {
        await _sdr.sessionServiceClient.updateSessionPlatformInformation(
          UpdateSessionPlatformInformationReq()
            ..platform = await getPlatformPB(),
        );
        unawaited(_sharedDao.put(SHARED_DAO_VERSION, VERSION));
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  bool shouldUpdateSessionPlatformInformation(String previousVersion) =>
      previousVersion != VERSION;

  bool shouldShowNewFeaturesDialog(String? previousVersion) =>
      previousVersion != VERSION;

  Future<bool> verifyQrCodeToken(String token) async {
    try {
      await _sdr.sessionServiceClient.verifyQrCodeToken(
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
      await _sdr.sessionServiceClient
          .revokeSession(RevokeSessionReq(sessionIds: [session]));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> revokeAllOtherSession() async {
    try {
      await _sdr.sessionServiceClient
          .revokeAllOtherSessions(RevokeAllOtherSessionsReq());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _sdr.sessionServiceClient.logoutSession(LogoutSessionReq());
    } catch (_) {}
  }

  Future<String> getName() async {
    final account = await getAccount();

    return buildName(account!.firstname, account.lastname);
  }

  Future<bool> shouldShowNewFeatureDialog() async {
    final pv = await _sharedDao.get(SHARED_DAO_DB_VERSION);
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
