// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/box/dao/account_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/settings.dart';
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

  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  final _authRepo = GetIt.I.get<AuthRepo>();
  final _accountDao = GetIt.I.get<AccountDao>();
  final _dbManager = GetIt.I.get<DBManager>();

  Future<bool> hasProfile({bool retry = false}) async {
    if (settings.hasProfile.value) {
      return true;
    }
    final account = getAccount();
    if (account != null && account.firstname != null) {
      settings.hasProfile.set(true);
      return true;
    }
    try {
      return _checkHasProfileByServer();
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return hasProfile();
      } else {
        return false;
      }
    }
  }

  Future<bool> _checkHasProfileByServer() async {
    if (await getUserProfileFromServer()) {
      unawaited(GetIt.I.get<ContactRepo>().getContacts());
      return true;
    }
    return false;
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
      unawaited(_fetchCurrentUserId());
      settings.hasProfile.set(true);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _fetchCurrentUserId({
    bool retry = false,
  }) async {
    try {
      final account = getAccount();
      if ((account == null || account.username == null)) {
        final getIdRequest = await _sdr.queryServiceClient
            .getIdByUid(GetIdByUidReq()..uid = _authRepo.currentUserUid);

        _accountDao.updateAccount(username: getIdRequest.id);
      }
    } catch (e) {
      _logger.e(e);
      if (retry) {
        unawaited(_fetchCurrentUserId());
      }
    }
  }

  Account? getAccount() {
    final account = _accountDao.getAccount();
    if (account != Account.empty) {
      return account;
    }
    return null;
  }

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
      _accountDao.updateAccount(
        email: res.profile.email,
      );
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
      final account = getAccount();

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
      _accountDao.updateAccount(passwordProtected: true);
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
        _accountDao.updateAccount(passwordProtected: false);
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
    try {
      final applicationVersion = settings.applicationVersion.value;
      final dbHashCode = settings.dbHashCode.value;
      if (applicationVersion.isEmpty || applicationVersion != APP_VERSION) {
        if (dbHashCode != _dbManager.getDbVersionHashcode()) {
          try {
            try {
              await _dbManager.migrate(removeOld: true);
            } catch (_) {}

            settings.allRoomFetched.set(false);
            settings.lastRoomMetadataUpdateTime.set(0);
            settings.onceShowNewVersionInformation.reset();
          } catch (e) {
            _logger.e(e);
          }
          settings.dbHashCode.set(_dbManager.getDbVersionHashcode());
        }
        unawaited(_updateSessionInformationIfNeed());
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _updateSessionInformationIfNeed() async {
    try {
      final applicationVersion = settings.applicationVersion.value;
      if (applicationVersion.isEmpty ||
          shouldUpdateSessionPlatformInformation(applicationVersion)) {
        await updatePlatformVersion();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> updatePlatformVersion() async {
    try {
      await _sdr.sessionServiceClient.updateSessionPlatformInformation(
        UpdateSessionPlatformInformationReq()..platform = await getPlatformPB(),
      );
      settings.applicationVersion.set(APP_VERSION);
    } catch (e) {
      _logger.e(e);
    }
  }

  bool shouldUpdateSessionPlatformInformation(String previousVersion) =>
      previousVersion != APP_VERSION;

  bool shouldShowNewFeaturesDialog(String previousVersion) =>
      previousVersion != APP_VERSION;

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

  String getName() {
    final account = getAccount();

    return buildName(account!.firstname, account.lastname);
  }

  bool shouldShowNewFeatureDialog() {
    return shouldShowNewFeaturesDialog(settings.applicationVersion.value);
  }

  Future<bool> isTwoStepVerificationEnabled() async {
    return (_accountDao.getAccount()).passwordProtected ?? false;
  }

  Future<bool> changeTwoStepVerificationPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO(dansi): implement later if server side completed
    return true;
  }
}
