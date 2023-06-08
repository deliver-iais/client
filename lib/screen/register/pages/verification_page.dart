import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/register/pages/two_step_verification_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/methods/format_duration.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/intro_widget.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_api_availability_android/google_api_availability_android.dart';
import 'package:google_api_availability_platform_interface/google_api_availability_platform_interface.dart';
import 'package:logger/logger.dart';
import 'package:pinput/pinput.dart';
import 'package:rxdart/rxdart.dart';

class VerificationPage extends StatefulWidget {
  final VerificationType verificationType;

  const VerificationPage({super.key, required this.verificationType});

  @override
  VerificationPageState createState() => VerificationPageState();
}

class VerificationPageState extends State<VerificationPage> {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _focusNode = FocusNode();
  final _showError = BehaviorSubject.seeded(false);
  final _isLoading = BehaviorSubject.seeded(false);
  final _verificationType = BehaviorSubject.seeded(VerificationType.SMS);
  late final Future<bool> googleApiAvailabilityAndroidFuture;
  final _pinController = TextEditingController();

  @override
  void initState() {
    _verificationType.add(widget.verificationType);
    if (isAndroidNative) {
      googleApiAvailabilityAndroidFuture = _checkGoogleApiServiceAvailability();
    } else {
      googleApiAvailabilityAndroidFuture = Future.value(false);
    }
    super.initState();
  }

  Future<bool> _checkGoogleApiServiceAvailability() async {
    try {
      return (await GoogleApiAvailabilityAndroid
              .checkGooglePlayServicesAvailability()) ==
          GooglePlayServicesAvailability.success;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  void _sendVerificationCode() {
    _showError.add(false);
    _isLoading.add(true);

    FocusScope.of(context).requestFocus(_focusNode);
    final result = _authRepo.sendVerificationCode(
      _pinController.text.replaceFarsiNumber(),
    );
    result.then((accessTokenResponse) {
      if (accessTokenResponse.status == AccessTokenRes_Status.OK) {
        _navigationToHome();
      } else if (accessTokenResponse.status ==
          AccessTokenRes_Status.PASSWORD_PROTECTED) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) {
              return TwoStepVerificationPage(
                verificationCode: _pinController.text,
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

  Future<void> _navigationToHome() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (c) => const HomePage(),
        ),
        (r) => false,
      );

  void _setErrorAndResetCode() {
    _showError.add(true);
    _isLoading.add(false);
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = settings.introThemeData;
    return Theme(
      data: theme,
      child: IntroWidget(
        child: Scaffold(
          floatingActionButton: StreamBuilder<bool>(
            stream: _isLoading,
            builder: (context, snapshot) {
              return TextButton(
                onPressed: snapshot.data == true
                    ? null
                    : () => _sendVerificationCode(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snapshot.data == true)
                      Container(
                        width: p16,
                        height: p16,
                        margin: const EdgeInsetsDirectional.only(end: p8),
                        child: CircularProgressIndicator(
                          color: theme.disabledColor,
                          strokeWidth: 2,
                        ),
                      ),
                    Text(
                      _i18n.get("start"),
                      key: const Key('start'),
                    ),
                  ],
                ),
              );
            },
          ),
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(
              _i18n.get("verification"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              children: <Widget>[
                const Center(
                  child: Ws.asset(
                    "assets/animations/code.ws",
                    repeat: false,
                    height: 150,
                    width: 150,
                  ),
                ),
                StreamBuilder<VerificationType>(
                  initialData: VerificationType.MESSAGE,
                  stream: _verificationType.stream,
                  builder: (context, verificationTypeSnapshot) {
                    if (verificationTypeSnapshot.hasData &&
                        verificationTypeSnapshot.data != null) {
                      return Text(
                        "${_i18n.get("enter_code")}. ${verificationTypeSnapshot.data! == VerificationType.MESSAGE ? _i18n.get("verification_code_send_in_other_device") : _i18n.get("verification_code_send_by_sms")}",
                        textDirection: _i18n.defaultTextDirection,
                        style: theme.textTheme.titleMedium,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: p16),
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: p8),
                  child: StreamBuilder<bool>(
                    stream: _isLoading,
                    builder: (context, snapshot) {
                      return FutureBuilder<bool>(
                        future: googleApiAvailabilityAndroidFuture,
                        builder: (context, smsAutofillSnapshot) {
                          if (!smsAutofillSnapshot.hasData) {
                            return const SizedBox();
                          }
                          return StreamBuilder<bool>(
                            stream: _showError,
                            builder: (context, showError) {
                              final forceErrorState = showError.data ?? false;
                              return Center(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Pinput(
                                    controller: _pinController,
                                    length: 5,
                                    focusNode: _focusNode,
                                    autofocus: true,
                                    androidSmsAutofillMethod:
                                        smsAutofillSnapshot.data!
                                            ? AndroidSmsAutofillMethod
                                                .smsUserConsentApi
                                            : AndroidSmsAutofillMethod.none,
                                    listenForMultipleSmsOnAndroid: true,
                                    inputFormatters: [NumberInputFormatter],
                                    hapticFeedbackType:
                                        HapticFeedbackType.lightImpact,
                                    onCompleted: (_) => _sendVerificationCode(),
                                    cursor: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 9),
                                          width: 22,
                                          height: 1,
                                          // color: focusedBorderColor,
                                        ),
                                      ],
                                    ),
                                    forceErrorState: forceErrorState,
                                    errorText: _i18n.get("wrong_code"),
                                    errorPinTheme:
                                        errorPinTheme(theme, fontSize: 43),
                                    defaultPinTheme:
                                        defaultPinTheme(theme, fontSize: 43),
                                    focusedPinTheme:
                                        focusedPinTheme(theme, fontSize: 43),
                                    submittedPinTheme:
                                        submittedPinTheme(theme, fontSize: 43),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _isLoading,
                  initialData: false,
                  builder: (context, snapshot) {
                    return !(snapshot.data ?? false)
                        ? Padding(
                            padding: const EdgeInsets.only(top: p16),
                            child: StreamBuilder<int>(
                              stream: _authRepo.watchResendTimer(),
                              builder: (c, timer) {
                                if (timer.hasData &&
                                    timer.data != null &&
                                    timer.data! > 0) {
                                  return Text("${_i18n.get(
                                    "you_can_request_an_sms_after",
                                  )} ${formatDuration(
                                    Duration(seconds: timer.data!),
                                  )}");
                                }
                                return StreamBuilder<VerificationType>(
                                  stream: _verificationType.stream,
                                  builder: (context, verificationTypeSnapshot) {
                                    if (verificationTypeSnapshot.hasData &&
                                        verificationTypeSnapshot.data != null) {
                                      return TextButton(
                                        onPressed: () async {
                                          try {
                                            _verificationType.add(
                                              await _authRepo
                                                  .getVerificationCode(
                                                forceToSendSms: true,
                                              ),
                                            );
                                          } catch (_) {
                                            _logger.e(_);
                                          }
                                        },
                                        child: Text(
                                          verificationTypeSnapshot.data! ==
                                                  VerificationType.MESSAGE
                                              ? _i18n.get(
                                                  "get_verification_code_by_sms",)
                                              : _i18n.get("resend_sms_code"),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                );
                              },
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
