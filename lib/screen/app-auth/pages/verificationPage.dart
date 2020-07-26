import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/generated-protocol/pub/v1/profile.pb.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedinStatus.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  var loggedinUserId = '';
  String verificationCode;
  var profileRepo = GetIt.I.get<ProfileRepo>();

  void _listenOpt() async {
    await SmsAutoFill().listenForCode;
  }

  _setVerificationCode(String code) {
    verificationCode = code;
  }

  _getLoggedinUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loggedinStatus', enumToString(LoggedinStatus.loggedin));
    loggedinUserId = prefs.getString('loggedinUserId');
  }

  _navigationToHome() {
    print("hi");
    var currentPageService = GetIt.I.get<CurrentPageService>();
    currentPageService.setToHome();
    _getLoggedinUserId()
        .then((value) => ExtendedNavigator.of(context).pushNamedAndRemoveUntil(
              Routes.homePage(id: loggedinUserId),
              (_) => false,
            ));
  }

  _saveTokensInSharedPreferences(String accessToken , String refreshToken) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs
        .setString(
            "accessToken",accessToken)
        .then((value) => _prefs
            .setString(
              "refreshToken",refreshToken ,
            ));
    print("saved");
  }

  @override
  void initState() {
    super.initState();
    _listenOpt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Center(
          child: Text(
            "Verification",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Container()),
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Text(
                    "We’ve sent an SMS with an activation code to your phone",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: ExtraTheme.of(context).secondColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: TextFieldPinAutoFill(
                      // onCodeSubmitted: _navigationToHome(),
                      codeLength: 5,
                      onCodeChanged: (val) => _setVerificationCode(val),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 80),
                        hintText: "Verification Code",
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ExtraTheme.of(context).text,
                          fontSize: 16,
                        ),
                        counterText: "",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: RaisedButton(
                child: Text(
                  "NEXT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14.5,
                  ),
                ),
                color: Theme.of(context).backgroundColor,
                onPressed: () {
                  var result =
                      profileRepo.sendVerificationCode(verificationCode);
                  result.then((value) {
                    AccessTokenRes accessTokenRequest = value as AccessTokenRes;
                    if (accessTokenRequest.status == AccessTokenRes_Status.OK) {
                      print("a=" + accessTokenRequest.accessToken);
                      print("b=" + accessTokenRequest.refreshToken);
                      _navigationToHome();
                      _saveTokensInSharedPreferences(accessTokenRequest.accessToken,accessTokenRequest.refreshToken);
                    } else if (accessTokenRequest.status ==
                        AccessTokenRes_Status.NOT_VALID) {
                      Fluttertoast.showToast(
                          msg: "Verification Code Not valid");
                    } else if (accessTokenRequest.status ==
                        AccessTokenRes_Status.PASSWORD_PROTECTED) {
                      print("PASSWORD_PROTECTED");
                    }
                  }).catchError((e) {
                    print(e.toString());
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
