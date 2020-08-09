import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedInStatus.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/shared/Widget/textField.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> with CodeAutoFill {
  String otpCode;
  String inpCode;
  bool showError = false;
  var loggedInUserId = '';
  String verificationCode;
  var profileRepo = GetIt.I.get<ProfileRepo>();

  void _listenOpt() async {
    await SmsAutoFill().listenForCode;
  }

  _setVerificationCode(String code) {
    verificationCode = code;
    if (verificationCode.length == 5) {
      _sendVerificationCode();
    }
  }

  _sendVerificationCode() {
    var result = profileRepo.sendVerificationCode(verificationCode);
    result.then((value) {
      AccessTokenRes accessTokenRequest = value as AccessTokenRes;
      if (accessTokenRequest.status == AccessTokenRes_Status.OK) {
        _navigationToHome();
        _saveTokensInSharedPreferences(
            accessTokenRequest.accessToken, accessTokenRequest.refreshToken);
      } else if (accessTokenRequest.status == AccessTokenRes_Status.NOT_VALID) {
        Fluttertoast.showToast(msg: "Verification Code Not valid");
      } else if (accessTokenRequest.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        Fluttertoast.showToast(msg: "PASSWORD_PROTECTED");
        print("PASSWORD_PROTECTED");
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  _getloggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loggedInStatus', enumToString(LoggedInStatus.loggedIn));
    loggedInUserId = prefs.getString('loggedInUserId');
  }

  _navigationToHome() {
    print("hi");
    var currentPageService = GetIt.I.get<CurrentPageService>();
    currentPageService.setToHome();
    _getloggedInUserId()
        .then((value) => ExtendedNavigator.of(context).pushNamedAndRemoveUntil(
              Routes.homePage(id: loggedInUserId),
              (_) => false,
            ));
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
        title: Padding(
          padding: const EdgeInsets.only(left: 50.0),
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
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: ExtraTheme.of(context).secondColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                        child: TextFieldId(
                      setColor: true,
                      setbacroundColor: true,
                      fontSize: 14,
                      hint: "Verification Code",
                      onChange: (val) => _setVerificationCode(val),
                      maxLength: 5,
                      widgetkey: "verificationCode",
                    )),
                  ),
                ),
                showError ? Text('Code is wrong') : Container(),
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
                  _sendVerificationCode();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void codeUpdated() {
    // setState(() {
    otpCode = code;
    print('hello');
    print(code);
    // });
  }
}
