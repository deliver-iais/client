// ignore_for_file: file_names

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/models/account.dart';
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
  final _dbManager = GetIt.I.get<DBManager>();

  Future<bool> hasProfile({bool retry = false}) async {
    if (await _sharedDao.get(SHARED_DAO_FIRST_NAME) != null) {
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
            twoStepVerificationEnabled: TWO_STEP_VERIFICATION_IS_AVAILABLE, //todo server side
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
      final res = await _sharedDao.get(SHARED_DAO_USERNAME);
      if (res != null) {
        return true;
      }
      final getIdRequest = await _queryServiceClient
          .getIdByUid(GetIdByUidReq()..uid = _authRepo.currentUserUid);
      if (getIdRequest.id.isNotEmpty) {
        _sharedDao.put(SHARED_DAO_USERNAME, getIdRequest.id);
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

  Future<Account> getAccount() async => Account()
    ..countryCode = (await _sharedDao.get(SHARED_DAO_COUNTRY_CODE) ?? "")
    ..nationalNumber = (await _sharedDao.get(SHARED_DAO_NATIONAL_NUMBER) ?? "")
    ..userName = await _sharedDao.get(SHARED_DAO_USERNAME) ?? ""
    ..firstName = await _sharedDao.get(SHARED_DAO_FIRST_NAME) ?? ""
    ..lastName = await _sharedDao.get(SHARED_DAO_LAST_NAME)
    ..email = await _sharedDao.get(SHARED_DAO_EMAIL)
    ..description = await _sharedDao.get(SHARED_DAO_DESCRIPTION);

  Future<bool> checkUserName(String username) async {
    final checkUsernameRes = await _queryServiceClient
        .idIsAvailable(IdIsAvailableReq()..id = username);
    return checkUsernameRes.isAvailable;
  }

  Future<bool> setAccountDetails(
    String? username,
    String? firstName,
    String? lastName,
    String? email,
  ) async {
    try {
      _queryServiceClient.setId(SetIdReq()..id = username!);

      final saveUserProfileReq = SaveUserProfileReq();
      if (firstName != null) {
        saveUserProfileReq.firstName = firstName;
      }
      if (lastName != null) {
        saveUserProfileReq.lastName = lastName;
      }
      if (email != null) {
        saveUserProfileReq.email = email;
      }

      _profileServiceClient.saveUserProfile(saveUserProfileReq);
      _saveProfilePrivateData(
        username: username,
        firstName: firstName ?? "",
        lastName: lastName ?? "",
        email: email ?? "",
      );

      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> enableTwoStepVerification(String pas) async {
    try {
      final account = await getAccount();
      await _profileServiceClient.saveUserProfile(
        SaveUserProfileReq()
          ..passwordHash = pas
          ..email = account.email!
          ..firstName = account.firstName!
          ..lastName = account.lastName!,
      );
      _sharedDao.putBoolean(SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED, true);
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<bool> disableTwoStepVerification(String password) async {
    try {
      //todo disable password _
      _sharedDao.putBoolean(SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED, false);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _savePhoneNumber(int countryCode, int nationalNumber) {
    _sharedDao
      ..put(SHARED_DAO_COUNTRY_CODE, countryCode.toString())
      ..put(SHARED_DAO_NATIONAL_NUMBER, nationalNumber.toString());
  }

  void _saveProfilePrivateData({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? twoStepVerificationEnabled,
  }) {
    if (username != null) _sharedDao.put(SHARED_DAO_USERNAME, username);
    _sharedDao
      ..put(SHARED_DAO_FIRST_NAME, firstName!)
      ..put(SHARED_DAO_LAST_NAME, lastName!)
      ..put(SHARED_DAO_EMAIL, email!);
    if (twoStepVerificationEnabled != null) {
      _sharedDao.putBoolean(
        SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED,
        twoStepVerificationEnabled,
      );
    }
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
        _sessionServicesClient.updateSessionPlatformInformation(
          UpdateSessionPlatformInformationReq()
            ..platform = await getPlatformPB(),
        );
      }
      // Update version in DB
    } else {
      _sharedDao.put(SHARED_DAO_APP_VERSION, VERSION);
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
      _sessionServicesClient
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

    return buildName(account.firstName, account.lastName);
  }

  Future<bool> shouldShowNewFeatureDialog() async {
    final pv = await _sharedDao.get(SHARED_DAO_APP_VERSION);
    return shouldShowNewFeaturesDialog(pv);
  }

  Future<bool> isTwoStepVerificationEnabled() async {
    return _sharedDao.getBoolean(SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED);
  }

  Future<bool> changeTwoStepVerificationPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    //todo
    return true;
  }
}
