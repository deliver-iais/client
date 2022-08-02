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
import 'package:deliver/screen/settings/pages/language_settings.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';

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
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final _formKey = GlobalKey<FormState>();
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  bool loginWithQrCode = isDesktop;
  bool _acceptPrivacy = kDebugMode;
  final loginToken = BehaviorSubject.seeded(randomAlphaNumeric(36));
  Timer? checkTimer;
  Timer? tokenGeneratorTimer;
  PhoneNumber? phoneNumber;
  final TextEditingController controller = TextEditingController();

  final BehaviorSubject<bool> _networkError = BehaviorSubject.seeded(false);

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

  @override
  void dispose() {
    loginToken.close();
    if (checkTimer != null) checkTimer!.cancel();
    if (tokenGeneratorTimer != null) tokenGeneratorTimer!.cancel();
    super.dispose();
  }

  Future<void> checkAndGoNext({bool doNotCheckValidator = false}) async {
    final navigatorState = Navigator.of(context);

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
          _networkError.add(true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidWidget(
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            centerTitle: true,
            title: Text(_i18n.get("login")),
            backgroundColor: theme.colorScheme.background,
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
          Text(
            textDirection:
                _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
            "1. ${_i18n.get("login_page_open_app_1")} $APPLICATION_NAME ${_i18n.get("login_page_open_app_2")}",
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection:
                _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textDirection:
                      _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                  "2. ${_i18n.get("login_page_qr_code_1")}",
                ),
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.qr_code_rounded, size: 17),
                ),
                Text(
                  textDirection:
                      _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                  _i18n.get("login_page_qr_code_2"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            textDirection:
                _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
            "3. ${_i18n.get("login_page_confirm_login")}",
          ),
          const SizedBox(height: 30),
          TextButton(
            child: Text(
              _i18n.get("access_to_authenticated_phone"),
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
                      const SizedBox(height: 20),
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
                          if (_acceptPrivacy) checkAndGoNext();
                        },
                        key: const Key("IntlPhoneField"),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        i18n.get("insert_phone_and_code"),
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _acceptPrivacy,
                            onChanged: (c) {
                              setState(() {
                                _acceptPrivacy = c!;
                              });
                            },
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptPrivacy = true;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: buildText(
                                    "${!_i18n.isRtl() ? _i18n.get("i_read_and_accept") : ""}[${_i18n.get("privacy_policy")}]($APPLICATION_TERMS_OF_USE_URL) ${_i18n.isRtl() ? _i18n.get("i_read_and_accept") : ""}",
                                    context,
                                  ),
                                  style: theme.textTheme.bodyText2,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: secondaryBorder,
                  ),
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  child: SettingsTile(
                    title: _i18n.get("language"),
                    subtitle: _i18n.locale.language().name,
                    leading: const FaIcon(FontAwesomeIcons.globe),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) {
                            return const LanguageSettingsPage(
                              rootFromLoginPage: true,
                            );
                          },
                        ),
                      );
                      // _routingService.openLanguageSettings();
                    },
                  ),
                ),
                StreamBuilder<bool>(
                  initialData: false,
                  stream: _networkError.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      return Container(
                        height: 40,
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: secondaryBorder,
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
                Row(
                  children: [
                    if (isDesktop)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                            child: Text(
                              _i18n.get("login_with_qr_code"),
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
                        ),
                      ),
                    const Spacer(),
                    if (_acceptPrivacy)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: checkAndGoNext,
                          child: Text(
                            i18n.get("next"),
                            key: const Key('next'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  List<InlineSpan> buildText(
    String text,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return onePath(
      [Block(text: text, features: {})],
      detectorsWithSearchTermDetector(),
      inlineSpanTransformer(
        defaultColor: theme.colorScheme.primary,
        linkColor: theme.colorScheme.primary,
        onUrlClick: (text) => _urlHandlerService.onUrlTap(text, context),
      ),
    );
  }
}
