import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/register/pages/two_step_verification_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _focusNode = FocusNode();
  bool _showError = false;

  String? _verificationCode;

  void _sendVerificationCode() {
    if ((_verificationCode!.length) < 5) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _showError = false);
    FocusScope.of(context).requestFocus(FocusNode());
    final result = _authRepo.sendVerificationCode(_verificationCode!);
    result.then((accessTokenResponse) {
      if (accessTokenResponse.status == AccessTokenRes_Status.OK) {
        _fireBaseServices.sendFireBaseToken();
        _navigationToHome();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) {
              return TwoStepVerificationPage(
                verificationCode: _verificationCode,
                accessTokenRes: accessTokenResponse,
                navigationToHomePage: _navigationToHome,
              );
            },
          ),
        );
      } else {
        ToastDisplay.showToast(
          toastText: _i18n.get("verification_code_not_valid"),
          toastContext: context,
        );
        _setErrorAndResetCode();
      }
    }).catchError((e) {
      _logger.e(e);
      _setErrorAndResetCode();
    });
  }

  Future<void> _navigationToHome() async {
    final navigatorState = Navigator.of(context);
    _contactRepo.getContacts().ignore();

    if (await _accountRepo.hasProfile(retry: true)) {
      unawaited(_accountRepo.fetchCurrentUserId(retry: true));
      navigatorState.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (c) {
            return const HomePage();
          },
        ),
        (r) => false,
      ).ignore();
    } else {
      navigatorState.push(
        MaterialPageRoute(
          builder: (c) {
            return const AccountSettings(forceToSetName: true);
          },
        ),
      ).ignore();
    }
  }

  void _setErrorAndResetCode() {
    setState(() {
      _showError = true;
      _verificationCode = "";
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidWidget(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        floatingActionButton: TextButton(
          onPressed: _sendVerificationCode,
          child: Text(
            _i18n.get("start"),
            key: const Key('start'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: 14.5,
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          title: Text(
            _i18n.get("verification"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
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
                  const SizedBox(height: 30),
                  const Icon(Icons.message, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    _i18n.get("enter_code"),
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    textDirection: _i18n.defaultTextDirection,
                    _i18n.get("we_have_send_a_code"),
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                    child: PinFieldAutoFill(
                      key: const Key("verificationCode"),
                      autoFocus: true,
                      focusNode: _focusNode,
                      codeLength: 5,
                      cursor: Cursor(color: theme.focusColor, enabled: true),
                      decoration: UnderlineDecoration(
                        colorBuilder: PinListenColorBuilder(
                          theme.primaryColor,
                          theme.colorScheme.secondary,
                        ),
                        textStyle: theme.primaryTextTheme.headlineSmall!
                            .copyWith(color: theme.primaryColor),
                      ),
                      currentCode: _verificationCode,
                      onCodeSubmitted: (code) {
                        _verificationCode = code;
                        _logger.d(_verificationCode);
                        _sendVerificationCode();
                      },
                      onCodeChanged: (code) {
                        if (code != null) {
                          _logger.d(_verificationCode);
                          _verificationCode = code;
                          if (code.length == 5) {
                            _sendVerificationCode();
                          }
                        }
                      },
                    ),
                  ),
                  if (_showError)
                    Text(
                      _i18n.get("wrong_code"),
                      style: theme.primaryTextTheme.titleMedium!
                          .copyWith(color: theme.colorScheme.error),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
