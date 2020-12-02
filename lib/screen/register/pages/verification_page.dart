import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/shared/fluid.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _showError = false;
  String _verificationCode;
  AppLocalization _appLocalization;

  final FocusNode focusNode = FocusNode();

  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();

  var _fireBaseServices = GetIt.I.get<FireBaseServices>();

  _sendVerificationCode() {
    if ((_verificationCode?.length ?? 0) < 5) {
      setState(() {
        _showError = true;
      });
      return;
    }
    setState(() {
      _showError = false;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    var result = _accountRepo.sendVerificationCode(_verificationCode);
    result.then((accessTokenResponse) {
      if (accessTokenResponse.status == AccessTokenRes_Status.OK) {
        _accountRepo.saveTokens(accessTokenResponse);
        _fireBaseServices.sendFireBaseToken(context);
        _showSyncContactDialog();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        Fluttertoast.showToast(msg: "PASSWORD_PROTECTED");
        // TODO navigate to password validation page
      } else {
        Fluttertoast.showToast(
            msg: _appLocalization
                .getTraslateValue("verification_Code_Not_Valid"));
        _setErrorAndResetCode();
      }
    }).catchError((e) {
      _setErrorAndResetCode();
    });
  }

  _navigationToHome() async {
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }
  _showSyncContactDialog(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 80,
              color: Colors.blue,
              child: Icon(
                Icons.contacts,
                color: Colors.white,
                size: 40,
              ),
            ),
            content: Text(_appLocalization.getTraslateValue("send_Contacts_message"),
                style: TextStyle(color: Colors.black, fontSize: 18)),
            actions: <Widget>[
              GestureDetector(
                child: Text(
                  _appLocalization.getTraslateValue("continue"),
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                onTap: () {
                  _navigationToHome();
                },
              )
            ],
          );
        });

  }

  _setErrorAndResetCode() {
    setState(() {
      _showError = true;
      _verificationCode = "";
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return FluidWidget(
      child: Scaffold(
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
            _appLocalization.getTraslateValue("verification"),
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
                    _appLocalization.getTraslateValue("enter_code"),
                    style: Theme.of(context).primaryTextTheme.headline5,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    _appLocalization.getTraslateValue("sendCode"),
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
                          colorBuilder: PinListenColorBuilder(
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor),
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .headline4
                              .copyWith(color: Theme.of(context).primaryColor)),
                      currentCode: _verificationCode,
                      onCodeSubmitted: (code) {
                        _verificationCode = code;
                        _sendVerificationCode();
                      },
                      onCodeChanged: (code) {
                        _verificationCode = code;
                        if (code.length == 5) {
                          _sendVerificationCode();
                        }
                      },
                    ),
                  ),
                  _showError
                      ? Text(
                          _appLocalization.getTraslateValue("wrongCode"),
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
      ),
    );
  }
}
