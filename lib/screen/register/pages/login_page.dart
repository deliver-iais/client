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
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/parsers/detectors.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver/shared/parsers/transformers.dart';
import 'package:deliver/shared/widgets/intro_widget.dart';
import 'package:deliver/shared/widgets/out_of_date.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';

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
  final _acceptPrivacyKey = GlobalKey<FormState>();
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  bool loginWithQrCode = isDesktopDevice;
  bool _acceptPrivacy = false;
  final loginToken = BehaviorSubject.seeded(randomAlphaNumeric(36));
  Timer? checkTimer;
  Timer? tokenGeneratorTimer;
  PhoneNumber? phoneNumber;
  final TextEditingController controller = TextEditingController();
  final ShakeWidgetController _shakeWidgetController = ShakeWidgetController();
  final BehaviorSubject<bool> _networkError = BehaviorSubject.seeded(false);
  int _maxLength = 10;
  int _minLength = 10;

  @override
  void initState() {
    if (phoneNumber != null) {
      controller.text = phoneNumber!.nationalNumber.toString();
    }

    if (isDesktopDevice) {
      checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await _loginByQrCode();
      });
      tokenGeneratorTimer =
          Timer.periodic(const Duration(seconds: 60), (timer) {
        loginToken.add(randomAlphaNumeric(36));
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

  Future<void> checkAndGoNext() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!(_acceptPrivacyKey.currentState?.validate() ?? false)) {
        unawaited(_shakeWidgetController.shake());
      } else {
        final navigatorState = Navigator.of(context);
        if (phoneNumber != null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = settings.introThemeData;
    return Theme(
      data: theme,
      child: IntroWidget(
        child: Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(_i18n.get("login")),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
            body: loginWithQrCode
                ? buildLoginWithQrCode(_i18n, theme)
                : buildNormalLogin(_i18n, theme),
          ),
        ),
      ),
    );
  }

  Widget buildLoginWithQrCode(I18N i18n, ThemeData theme) {
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
            textDirection: _i18n.defaultTextDirection,
            "1. ${_i18n.get("login_page_open_app_1")} $APPLICATION_NAME ${_i18n.get("login_page_open_app_2")}",
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                textDirection: _i18n.defaultTextDirection,
                "2. ${_i18n.get("login_page_qr_code_1")}",
              ),
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.qr_code_rounded, size: 17),
              ),
              Text(
                textDirection: _i18n.defaultTextDirection,
                _i18n.get("login_page_qr_code_2"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            textDirection: _i18n.defaultTextDirection,
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

  Widget buildNormalLogin(I18N i18n, ThemeData theme) {
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
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: IntlPhoneField(
                          initialCountryCode: phoneNumber != null
                              ? phoneNumber!.countryCode.toString()
                              : null,
                          controller: controller,
                          validator: (value) => value == null ||
                                  value.isEmpty ||
                                  value.length > _maxLength ||
                                  value.length < _minLength
                              ? i18n.get("invalid_mobile_number")
                              : null,
                          onChanged: (p) {
                            phoneNumber = p;
                          },
                          onMaxAndMinLengthChanged: (min, max) {
                            _maxLength = max;
                            _minLength = min;
                          },
                          onSubmitted: (p) {
                            phoneNumber = p;
                            if (_acceptPrivacy) checkAndGoNext();
                          },
                          key: const Key("IntlPhoneField"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        i18n.get("insert_phone_and_code"),
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: 24),
                      ShakeWidget(
                        controller: _shakeWidgetController,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: _acceptPrivacyKey,
                              child: FormField<bool>(
                                builder: (state) {
                                  return Checkbox(
                                    value: _acceptPrivacy,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptPrivacy = value ?? false;
                                        state.didChange(value);
                                      });
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (!_acceptPrivacy) {
                                    return 'You need to accept terms';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptPrivacy = !_acceptPrivacy;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: buildText(
                                      "${!_i18n.isRtl ? _i18n.get("i_read_and_accept") : ""}[${_i18n.get("privacy_policy")}]($APPLICATION_TERMS_OF_USE_URL) ${_i18n.isRtl ? _i18n.get("i_read_and_accept") : ""}",
                                      theme,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: secondaryBorder,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: SettingsTile(
                    title: _i18n.get("language"),
                    subtitle: _i18n.language.languageName,
                    leading: const Icon(CupertinoIcons.globe),
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
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
                    if (isDesktopDevice)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: TextButton(
                            child: Text(_i18n.get("login_with_qr_code")),
                            onPressed: () {
                              setState(() {
                                loginWithQrCode = true;
                              });
                            },
                          ),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: checkAndGoNext,
                        child: Text(
                          i18n.get("next"),
                          key: const Key('next'),
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

  List<InlineSpan> buildText(String text, ThemeData theme) {
    return onePath(
      [Block(text: text, features: {})],
      detectorsWithSearchTermDetector(),
      inlineSpanTransformer(
        defaultColor: theme.colorScheme.error,
        linkColor: theme.colorScheme.primary,
        codeBackgroundColor: theme.colorScheme.secondaryContainer,
        codeForegroundColor: theme.colorScheme.onSecondaryContainer,
        colorScheme: theme.colorScheme,
        onUrlClick: (text) => _urlHandlerService.onUrlTap(text),
      ),
    );
  }
}
