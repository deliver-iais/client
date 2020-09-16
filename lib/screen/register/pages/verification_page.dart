import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> with CodeAutoFill {
  String otpCode;
  bool showError = false;
  String verificationCode;
  AppLocalization appLocalization;
  final FocusNode focusNode = FocusNode();
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  var fireBaseServices = GetIt.I.get<FireBaseServices>();

  var checkPermission = GetIt.I.get<CheckPermissionsService>();

  @override
  void initState() {
    super.initState();
    _listenOpt();
  }

  void _listenOpt() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  void codeUpdated() {
    otpCode = code;
  }

  _sendVerificationCode() {
    if ((verificationCode?.length ?? 0) < 5) {
      setState(() {
        showError = true;
      });
      return;
    }
    setState(() {
      showError = false;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    var result = accountRepo.sendVerificationCode(verificationCode);
    result.then((accessTokenResponse) {
      if (accessTokenResponse.status == AccessTokenRes_Status.OK) {
        accountRepo.saveTokens(accessTokenResponse);
        _requestPermissions();
        fireBaseServices.sendFireBaseToken(context);
        _navigationToHome();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.NOT_VALID) {
        Fluttertoast.showToast(
            msg: appLocalization
                .getTraslateValue("verification_Code_Not_Valid"));
        _setErrorAndResetCode();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        Fluttertoast.showToast(msg: "PASSWORD_PROTECTED");
        Fimber.d("PASSWORD_PROTECTED");
        // TODO navigate to password validation page
      }
    }).catchError((e) {
      Fimber.d(e.toString());
      _setErrorAndResetCode();
    });
  }

  _requestPermissions() {
    checkPermission.checkContactPermission(context);
    checkPermission.checkStoragePermission();
  }

  _navigationToHome() {
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  _setErrorAndResetCode() {
    setState(() {
      showError = true;
      verificationCode = "";
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    return Scaffold(
      primary: true,
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        foregroundColor: Theme.of(context).buttonTheme.colorScheme.onPrimary,
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          _sendVerificationCode();
        },
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          appLocalization.getTraslateValue("verification"),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Icon(
                  Icons.message,
                  size: 50,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  appLocalization.getTraslateValue("enter_code"),
                  style: Theme.of(context).primaryTextTheme.headline5,
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  appLocalization.getTraslateValue("sendCode"),
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                  child: PinFieldAutoFill(
                    autofocus: true,
                    focusNode: focusNode,
                    codeLength: 5,
                    decoration: UnderlineDecoration(
                        enteredColor: Theme.of(context).primaryColor,
                        color: Theme.of(context).accentColor,
                        textStyle: Theme.of(context)
                            .primaryTextTheme
                            .headline4
                            .copyWith(color: Theme.of(context).primaryColor)),
                    currentCode: verificationCode,
                    onCodeSubmitted: (code) {
                      verificationCode = code;
                      _sendVerificationCode();
                    },
                    onCodeChanged: (code) {
                      Fimber.d(verificationCode);
                      verificationCode = code;
                      if (code.length == 5) {
                        _sendVerificationCode();
                      }
                    },
                  ),
                ),
                showError
                    ? Text(
                        appLocalization.getTraslateValue("wrongCode"),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1
                            .copyWith(color: Theme.of(context).errorColor),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
