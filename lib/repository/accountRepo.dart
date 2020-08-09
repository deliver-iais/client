import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:fimber/fimber_base.dart';
import 'package:get_it/get_it.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountRepo {
  static var fileDao = GetIt.I.get<FileDao>();
  static var avatarRepo = GetIt.I.get<AvatarDao>();
  static var profileRepo = GetIt.I.get<ProfileRepo>();
  Avatar avatar;
  PhoneNumber phoneNumber;

  Future getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    print("exp=" + decodedToken["exp"].toString());
    double expTime = double.parse(decodedToken["exp"].toString());
    double now = new DateTime.now().millisecondsSinceEpoch /1000;
    if (now > expTime) {
      String refreshToken = prefs.getString('refreshToken');
      await profileRepo.getAccessToken(refreshToken).then((value) {
        RenewAccessTokenRes renewAccessTokenRes = value as RenewAccessTokenRes;
        if (renewAccessTokenRes.status == RenewAccessTokenRes_Status.OK) {
          accessToken = renewAccessTokenRes.accessToken;
          _saveTokensInSharedPreferences(
              accessToken, renewAccessTokenRes.refreshToken);
        } else if (renewAccessTokenRes.status ==
            RenewAccessTokenRes_Status.NOT_VALID) {
          Fimber.d("NotValid");
        }
      });
    }
    return accessToken;
  }

  _saveTokensInSharedPreferences(
      String accessToken, String refreshToken) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs
        .setString("accessToken", accessToken)
        .then((value) => _prefs.setString(
              "refreshToken",
              refreshToken,
            ));
  }
}
