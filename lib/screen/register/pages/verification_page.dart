import 'package:auto_route/auto_route.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/routes/router.gr.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _focusNode = FocusNode();
  bool _showError = false;
  String _verificationCode;

  // TODO ???
  I18N _i18n;

  _sendVerificationCode() {
    if ((_verificationCode?.length ?? 0) < 5) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _showError = false);
    FocusScope.of(context).requestFocus(FocusNode());
    var result = _authRepo.sendVerificationCode(_verificationCode);
    result.then((accessTokenResponse) {
      if (accessTokenResponse.status == AccessTokenRes_Status.OK) {
        _fireBaseServices.sendFireBaseToken();
        _navigationToHome();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        ToastDisplay.showToast(toastText: "PASSWORD_PROTECTED",tostContext: context);
        // TODO navigate to password validation page
      } else {
        ToastDisplay.showToast(toastText: _i18n.get("verification_code_not_valid"),tostContext: context);
        _setErrorAndResetCode();
      }
    }).catchError((e) {
      _logger.e(e);
      _setErrorAndResetCode();
    });
  }

  _navigationToHome() async {
    _contactRepo.getContacts();
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  _setErrorAndResetCode() {
    setState(() {
      _showError = true;
      _verificationCode = "";
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
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
            _i18n.get("verification"),
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
                    _i18n.get("enter_code"),
                    style: TextStyle(
                        fontSize: 17, color: ExtraTheme.of(context).textField),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    _i18n.get("we_have_send_a_code"),
                    style: TextStyle(
                        fontSize: 17, color: ExtraTheme.of(context).textField),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                    child: PinFieldAutoFill(
                      autofocus: true,
                      focusNode: _focusNode,
                      codeLength: 5,
                      decoration: UnderlineDecoration(
                          colorBuilder: PinListenColorBuilder(
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor),
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .headline5
                              .copyWith(color: Theme.of(context).primaryColor)),
                      currentCode: _verificationCode,
                      onCodeSubmitted: (code) {
                        _verificationCode = code;
                        _logger.d(_verificationCode);
                        _sendVerificationCode();
                      },
                      onCodeChanged: (code) {
                        _logger.d(_verificationCode);
                        _verificationCode = code;
                        if (code.length == 5) {
                          _sendVerificationCode();
                        }
                      },
                    ),
                  ),
                  _showError
                      ? Text(
                          _i18n.get("wrong_code"),
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
