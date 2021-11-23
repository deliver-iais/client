import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/models/account.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver_public_protocol/pub/v1/models/platform.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
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

  Future<bool> getProfile({bool retry = false}) async {
    if (await _sharedDao.get(SHARED_DAO_COUNTRY_CODE) != null) {
      return true;
    }
    try {
      var result =
          await _profileServiceClient.getUserProfile(GetUserProfileReq());

      _savePhoneNumber(result.profile.phoneNumber.countryCode,
          result.profile.phoneNumber.nationalNumber.toInt());

      if (result.hasProfile() && result.profile.firstName.isNotEmpty) {
        _saveProfilePrivateData(
            firstName: result.profile.firstName,
            lastName: result.profile.lastName,
            email: result.profile.email);
        return await getUsername();
      } else
        return getUsername();
    } catch (e) {
      _logger.e(e);
      if (retry)
        return getProfile();
      else
        return false;
    }
  }

  Future<bool> getUsername() async {
    try {
      var getIdRequest = await _queryServiceClient
          .getIdByUid(GetIdByUidReq()..uid = _authRepo.currentUserUid);
      if (getIdRequest != null && getIdRequest.id.isNotEmpty) {
        _sharedDao.put(SHARED_DAO_USERNAME, getIdRequest.id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<Account> getAccount() async {
    return Account()
      ..countryCode = (await _sharedDao.get(SHARED_DAO_COUNTRY_CODE))
      ..nationalNumber = (await _sharedDao.get(SHARED_DAO_NATIONAL_NUMBER))
      ..userName = await _sharedDao.get(SHARED_DAO_USERNAME)
      ..firstName = await _sharedDao.get(SHARED_DAO_FIRST_NAME)
      ..lastName = await _sharedDao.get(SHARED_DAO_LAST_NAME)
      ..email = await _sharedDao.get(SHARED_DAO_EMAIL)
      ..password = await _sharedDao.get(SHARED_DAO_PASSWORD)
      ..description = await _sharedDao.get(SHARED_DAO_DESCRIPTION);
  }

  Future<bool> checkUserName(String username) async {
    var checkUsernameRes = await _queryServiceClient
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

      SaveUserProfileReq saveUserProfileReq = SaveUserProfileReq();
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
          firstName: firstName,
          lastName: lastName,
          email: email);

      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  _savePhoneNumber(int countryCode, int nationalNumber) {
    _sharedDao.put(SHARED_DAO_COUNTRY_CODE, countryCode.toString());
    _sharedDao.put(SHARED_DAO_NATIONAL_NUMBER, nationalNumber.toString());
  }

  _saveProfilePrivateData(
      {String? username, String? firstName, String? lastName, String? email}) {
    _sharedDao.put(SHARED_DAO_USERNAME, username!);
    _sharedDao.put(SHARED_DAO_FIRST_NAME, firstName!);
    _sharedDao.put(SHARED_DAO_LAST_NAME, lastName!);
    _sharedDao.put(SHARED_DAO_EMAIL, email!);
  }

  Future<String?> get notification =>
      _sharedDao.get(SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED);

  Future<void> fetchProfile() async {
    if (null == await _sharedDao.get(SHARED_DAO_USERNAME)) {
      await getUsername();
    } else if (null == await _sharedDao.get(SHARED_DAO_FIRST_NAME)) {
      await getProfile(retry: true);
    }
  }

  Future<List<Session>> getSessions() async {
    var res = await _sessionServicesClient.getMySessions(GetMySessionsReq());
    return res.sessions;
  }

  Future<void> checkUpdatePlatformSessionInformation() async {
    String? pv = await _sharedDao.get(SHARED_DAO_APP_VERSION);
    if (pv != null) {
      // Migrations
      if (shouldRemoveDB(pv)) {
        //  await _dbManager.deleteDB();
      }

      if (shouldMigrateDB(pv)) {
        await _dbManager.migrate(pv);
      }

      if (shouldUpdateSessionPlatformInformation(pv)) {
        Platform platform = Platform()..clientVersion = VERSION;
        platform = await _authRepo.getPlatForm(platform);
        _sessionServicesClient.updateSessionPlatformInformation(
            UpdateSessionPlatformInformationReq()..platform = platform);
      }

      // Update version in DB
      _sharedDao.put(SHARED_DAO_APP_VERSION, VERSION);
    }
  }

  shouldRemoveDB(String? previousVersion) {
    return previousVersion == null || previousVersion != VERSION;
  }

  shouldMigrateDB(String? previousVersion) {
    return false;
  }

  shouldUpdateSessionPlatformInformation(String previousVersion) {
    return previousVersion != VERSION;
  }

  Future<bool> verifyQrCodeToken(String token) async {
    try {
      await _sessionServicesClient.verifyQrCodeToken(VerifyQrCodeTokenReq()
        ..platform = await _authRepo.getPlatformDetails()
        ..token = token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSessions(List<String> sessions) async {
    try {
      await _sessionServicesClient
          .revokeSession(RevokeSessionReq(sessionIds: sessions));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> getName() async {
    final account = await getAccount();

    return buildName(account.firstName, account.lastName);
  }
}
