import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/register/pages/two_step_verification_page.dart';
import 'package:deliver/screen/register/pages/verification_page.dart';
import 'package:deliver/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver/screen/settings/pages/connection_setting_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  static final _logger = GetIt.I.get<Logger>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  static final _contactRepo = GetIt.I.get<ContactRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _accountRepo = GetIt.I.get<AccountRepo>();
  final _formKey = GlobalKey<FormState>();
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  bool loginWithQrCode = isDesktop;
  bool _acceptPrivacy = !isAndroid;
  final loginToken = BehaviorSubject.seeded(randomAlphaNumeric(36));
  Timer? checkTimer;
  Timer? tokenGeneratorTimer;
  PhoneNumber? phoneNumber;
  final TextEditingController controller = TextEditingController();

  final BehaviorSubject<bool> _setCustomIp = BehaviorSubject.seeded(false);

  @override
  void initState() {
    if (phoneNumber != null) {
      controller.text = phoneNumber!.nationalNumber.toString();
    }

    if (isDesktop) {
      checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await _loginByQrCode();
      });
      tokenGeneratorTimer =
          Timer.periodic(const Duration(seconds: 60), (timer) {
        loginToken.add(randomAlphaNumeric(36));
      });
    } else if (isAndroid && !kDebugMode) {
      SmsAutoFill().hint.then((value) {
        if (value != null) {
          final p = getPhoneNumber(value);
          if (p != null) {
            phoneNumber = p;
            controller.text = p.nationalNumber.toString();
            _isLoading.add(true);
            checkAndGoNext(doNotCheckValidator: true);
          }
        }
      });
    }
    super.initState();
  }

  Future<void> _loginByQrCode() async {
    try {
      final res = await _authRepo.checkQrCodeToken(loginToken.value);
      if (res.status == AccessTokenRes_Status.OK) {
        await _fireBaseServices.sendFireBaseToken();
        _navigationToHome();
      } else if (res.status == AccessTokenRes_Status.PASSWORD_PROTECTED) {
        if (!mounted) return;
        if (checkTimer != null) checkTimer!.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) {
              return TwoStepVerificationPage(
                token: loginToken.value,
                accessTokenRes: res,
                navigationToHomePage: _navigationToHome,
              );
            },
          ),
        ).ignore();
      }
    } on GrpcError catch (e) {
      if (e.code == StatusCode.aborted) {
        showOutOfDateDialog(context);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void _navigationToHome() {
    _contactRepo.getContacts();
    _accountRepo
      ..hasProfile(retry: true)
      ..fetchCurrentUserId(retry: true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (c) {
          return const HomePage();
        },
      ),
      (r) => false,
    );
  }

  void _loginASTestUser() {
    _authRepo.saveTestUserInfo();
    _navigationToHome();
  }

  @override
  void dispose() {
    loginToken.close();
    if (checkTimer != null) checkTimer!.cancel();
    if (tokenGeneratorTimer != null) tokenGeneratorTimer!.cancel();
    super.dispose();
  }

  Future<void> checkAndGoNext({bool doNotCheckValidator = false}) async {
    final navigatorState = Navigator.of(context);
    if (phoneNumber != null &&
        phoneNumber!.nationalNumber.toString() == TEST_USER_PHONE_NUMBER) {
      _logger.e("login as test user ");
      _loginASTestUser();
    } else {
      final isValidated = _formKey.currentState?.validate() ?? false;
      if ((doNotCheckValidator || isValidated) && phoneNumber != null) {
        _isLoading.add(true);
        try {
          await _authRepo.getVerificationCode(phoneNumber!);
          navigatorState
              .push(
                MaterialPageRoute(builder: (c) => const VerificationPage()),
              )
              .ignore();
          _isLoading.add(false);
        } on GrpcError catch (e) {
          _isLoading.add(false);
          _logger.e(e);
          if (e.code == StatusCode.unavailable) {
            _setCustomIp.add(true);
            ToastDisplay.showToast(
              toastText: _i18n.get("notwork_is_unavailable"),
              toastContext: context,
            );
          } else if (e.code == StatusCode.aborted) {
            showOutOfDateDialog(context);
          } else {
            ToastDisplay.showToast(
              toastText: _i18n.get("error_occurred"),
              toastContext: context,
            );
          }
        } catch (e) {
          _isLoading.add(false);
          _logger.e(e);
          ToastDisplay.showToast(
            toastText: _i18n.get("error_occurred"),
            toastContext: context,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidWidget(
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: Text(_i18n.get("login")),
            backgroundColor: theme.backgroundColor,
          ),
          body: loginWithQrCode
              ? buildLoginWithQrCode(_i18n, context)
              : buildNormalLogin(_i18n, context),
        ),
      ),
    );
  }

  Widget buildLoginWithQrCode(I18N i18n, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<String>(
            stream: loginToken,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.isNotEmpty) {
                return Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: QrImage(
                    data:
                        "https://$APPLICATION_DOMAIN/login?token=${snapshot.data}",
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.black,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          const SizedBox(height: 30),
          const Text("1. Open $APPLICATION_NAME on your phone"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("2. Go to QrCode reader by clicking"),
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.qr_code_rounded, size: 17),
              ),
              Text("in appbar"),
            ],
          ),
          const SizedBox(height: 10),
          const Text("3. Point your phone at this screen to confirm login"),
          const SizedBox(height: 30),
          TextButton(
            child: const Text(
              "Don't you have access to an authenticated phone?",
            ),
            onPressed: () {
              setState(() {
                loginWithQrCode = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildNormalLogin(I18N i18n, BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      initialData: _isLoading.value,
      stream: _isLoading,
      builder: (c, loading) {
        if (loading.hasData && loading.data != null && loading.data!) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 5),
                      IntlPhoneField(
                        initialCountryCode: phoneNumber != null
                            ? phoneNumber!.countryCode.toString()
                            : null,
                        controller: controller,
                        validator: (value) => value!.length != 10 ||
                                (value.isNotEmpty && value[0] == '0')
                            ? i18n.get("invalid_mobile_number")
                            : null,
                        onChanged: (p) {
                          phoneNumber = p;
                        },
                        onSubmitted: (p) {
                          phoneNumber = p;
                          checkAndGoNext();
                        },
                      ),
                      const SizedBox(height: 15),
                      Text(
                        i18n.get("insert_phone_and_code"),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: theme.primaryColor,
                          fontSize: 15,
                        ),
                      ),
                      if (isDesktop) const SizedBox(height: 40),
                      if (isDesktop)
                        TextButton(
                          child: Text(
                            "Login with QR Code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              loginWithQrCode = true;
                            });
                          },
                        ),
                      if (isAndroid)
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptPrivacy,
                              onChanged: (c) {
                                setState(() {
                                  _acceptPrivacy = c!;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptPrivacy = true;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "شرایط حریم خصوصی",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launchUrl(
                                              Uri.parse(
                                                "https://wemessenger.ir/terms",
                                              ),
                                            ),
                                    ),
                                    const TextSpan(
                                      text:
                                          " را مطالعه نموده ام و آن را قبول می کنم",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                  style: theme.textTheme.bodyText2,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: StreamBuilder<bool>(
                    initialData: false,
                    stream: _setCustomIp.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!) {
                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: tertiaryBorder,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_i18n.get("go_connection_setting_page")),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) {
                                        return const ConnectionSettingPage(
                                          rootFromLoginPage: true,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(_i18n.get("settings")),
                              )
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                if (_acceptPrivacy)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: checkAndGoNext,
                        child: Text(
                          i18n.get("next"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
