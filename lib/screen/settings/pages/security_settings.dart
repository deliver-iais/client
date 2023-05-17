import 'package:deliver/box/account.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/widgets/brand_image.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  SecuritySettingsPageState createState() => SecuritySettingsPageState();
}

class SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _newPasFormKey = GlobalKey<FormState>();
  final _currentPassFormKey = GlobalKey<FormState>();
  final _repPasFormKey = GlobalKey<FormState>();
  var _currentPass = "";
  var _pass = "";
  var _repeatedPass = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("security")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: ListView(
          children: [
            const BrandImage(
              text: "",
              imagePath: "assets/images/security.webp",
              alignment: Alignment(0.0, -0.4),
              topFreeHeight: 380,
            ),
            Section(
              title: _i18n.get("lock_app"),
              children: [
                SettingsTile.switchTile(
                  title: _i18n.get("enable_local_lock"),
                  leading: const Icon(CupertinoIcons.lock),
                  switchValue: _authRepo.isLocalLockEnabled(),
                  onToggle: ({required newValue}) {
                    if (newValue) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return setLocalPassword();
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return disableLocalPassword();
                        },
                      );
                    }
                  },
                ),
                if (_authRepo.isLocalLockEnabled())
                  SettingsTile(
                    title: _i18n.get("edit_password"),
                    leading: const Icon(Icons.edit),
                    onPressed: (c) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return setLocalPassword();
                        },
                      );
                    },
                    trailing: const SizedBox.shrink(),
                  ),
              ],
            ),
            if (TWO_STEP_VERIFICATION_IS_AVAILABLE)
              Section(
                title: _i18n.get("two_step_verification"),
                children: [
                  FutureBuilder<Account?>(
                    future: _accountRepo.getAccount(),
                    builder: (context, accountData) {
                      if (accountData.hasData && accountData.data != null) {
                        return SettingsTile.switchTile(
                          title: _i18n.get("two_step_verification"),
                          leading: const Icon(CupertinoIcons.lock_shield),
                          switchValue:
                              accountData.data!.passwordProtected ?? false,
                          onToggle: ({required newValue}) async {
                            if (newValue) {
                              if (accountData.data!.email != null &&
                                  accountData.data!.email!.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return enableOrUpdateTwoStepVerification(
                                      email: accountData.data!.email!,
                                      updatePassword: false,
                                    );
                                  },
                                ).ignore();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (c) {
                                    return AlertDialog(
                                      content: Text(
                                        _i18n.get("need_to_set_email"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(c);
                                            _routingService
                                                .openAccountSettings();
                                          },
                                          child: Text(_i18n.get("go_setting")),
                                        )
                                      ],
                                    );
                                  },
                                ).ignore();
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return disableTwoStepVerification();
                                },
                              ).ignore();
                            }
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  FutureBuilder<Account?>(
                    future: _accountRepo.getAccount(),
                    builder: (c, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.passwordProtected != null &&
                          snapshot.data!.passwordProtected!) {
                        return SettingsTile(
                          title:
                              _i18n.get("edit_two_step_verification_password"),
                          leading: const Icon(Icons.edit),
                          onPressed: (c) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return enableOrUpdateTwoStepVerification(
                                  email: snapshot.data!.email!,
                                  updatePassword: true,
                                );
                              },
                            );
                          },
                          trailing: const SizedBox.shrink(),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget disableLocalPassword() {
    return StatefulBuilder(
      builder: (context, setState2) {
        final theme = Theme.of(context);
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_i18n.get("current_password")),
              Pinput(
                obscureText: true,
                obscuringWidget: obscuringPinWidget(theme),
                inputFormatters: [NumberInputFormatter],
                autofocus: true,
                errorTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.red),
                defaultPinTheme: defaultPinTheme(theme),
                validator: (_) => _validatePin(_ ?? ""),
                onChanged: (p) {
                  setState2(() => _currentPass = p);
                },
                focusedPinTheme: focusedPinTheme(theme),
                submittedPinTheme: submittedPinTheme(theme),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_i18n.get("cancel")),
              ),
            ),
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: _currentPass.isNotEmpty
                    ? () {
                        if (_authRepo.localPasswordIsCorrect(_currentPass)) {
                          setState(() {
                            _authRepo.setLocalPassword("");
                          });
                          Navigator.of(context).pop();
                        } else {
                          // TODO(hasan): show error, https://gitlab.iais.co/deliver/wiki/-/issues/418
                        }
                      }
                    : null,
                child: Text(_i18n.get("disable")),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget disableTwoStepVerification() {
    final textController = TextEditingController();
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ws.asset(
              "assets/animations/lock.ws",
              width: 60,
              height: 60,
              delegates: LottieDelegates(
                values: [
                  ValueDelegate.color(
                    const ['**'],
                    value: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            TextField(
              controller: textController,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _i18n.get("current_password"),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            height: 40,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_i18n.get("cancel")),
            ),
          ),
          SizedBox(
            height: 40,
            child: TextButton(
              onPressed: () async {
                if (await _accountRepo
                    .disableTwoStepVerification(textController.text)) {
                  if (context.mounted) {
                    setState(() {});
                    Navigator.of(context).pop();
                  }
                } else {
                  if (context.mounted) {
                    ToastDisplay.showToast(
                      toastContext: context,
                      toastText: _i18n.get("incorrect_password"),
                    );
                  }
                }
              },
              child: Text(_i18n.get("disable")),
            ),
          ),
        ],
      ),
    );
  }

  Widget enableOrUpdateTwoStepVerification({
    required String email,
    required bool updatePassword,
  }) {
    final pasController = TextEditingController();
    final currentPasController = TextEditingController();
    final repPasController = TextEditingController();
    final hintPasController = TextEditingController();
    return StatefulBuilder(
      builder: (c, set) {
        return AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(c);
              },
              child: Text(
                _i18n.get("cancel"),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigatorState = Navigator.of(c);
                if ((!updatePassword ||
                        _currentPassFormKey.currentState!.validate()) &&
                    _newPasFormKey.currentState!.validate() &&
                    _repPasFormKey.currentState!.validate()) {
                  final isSet = await _accountRepo.updatePassword(
                    currentPassword: currentPasController.text,
                    newPassword: pasController.text,
                    passwordHint: hintPasController.text,
                  );
                  if (isSet) {
                    if (context.mounted) {
                      ToastDisplay.showToast(
                        toastContext: c,
                        toastText: updatePassword
                            ? _i18n.get("your_password_update")
                            : _i18n.get("two_step_verification_active"),
                      );
                    }

                    setState(() {});
                    navigatorState.pop();
                  } else {
                    if (context.mounted) {
                      ToastDisplay.showToast(
                        toastContext: c,
                        toastText: _i18n.get("error_occurred"),
                      );
                    }
                  }
                }
              },
              child: Text(_i18n.get("save")),
            )
          ],
          title: Text(_i18n.get("two_step_verification")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ws.asset(
                "assets/animations/lock.ws",
                width: 60,
                height: 60,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['**'],
                      value: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              if (updatePassword)
                Form(
                  key: _currentPassFormKey,
                  child: TextFormField(
                    controller: currentPasController,
                    obscureText: true,
                    validator: (s) {
                      if (s == null || s.isEmpty) {
                        return _i18n.get(
                          "current_password",
                        );
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: _i18n.get("current_password"),
                    ),
                  ),
                ),
              const SizedBox(
                height: 4,
              ),
              Form(
                key: _newPasFormKey,
                child: TextFormField(
                  controller: pasController,
                  obscureText: true,
                  validator: (s) {
                    const Pattern pattern =
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
                    final regex = RegExp(pattern.toString());
                    if (s == null || s.isEmpty) {
                      return _i18n.get("pas_not_empty");
                    } else if (!regex.hasMatch(s)) {
                      return _i18n.get("password_not_valid");
                    } else if (repPasController.text.isNotEmpty &&
                        s != repPasController.text) {
                      return _i18n.get("password_not_match");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    helperText: _i18n.get("password_helper"),
                    hintText: _i18n.get("new_password"),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _repPasFormKey,
                child: TextFormField(
                  controller: repPasController,
                  obscureText: true,
                  validator: (repPass) {
                    if (repPass == null || repPass.isEmpty) {
                      return _i18n.get("rep_pas_not_empty");
                    } else if (repPass != pasController.text) {
                      return _i18n.get("password_not_match");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: _i18n.get("repeat_password"),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: hintPasController,
                decoration: InputDecoration(
                  hintText: _i18n.get("password_hint"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                _i18n.get("two_step_verification_des"),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: email),
                decoration: InputDecoration(
                  labelText: _i18n.get("recovery_email"),
                  helperText: _i18n.get("email_for_two_step"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget setLocalPassword() {
    final checkCurrentPassword = _authRepo.isLocalLockEnabled();
    return StatefulBuilder(
      builder: (context, setState2) {
        final theme = Theme.of(context);
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (checkCurrentPassword) ...[
                Text(_i18n.get("current_password")),
                const SizedBox(height: 8),
                Pinput(
                  obscureText: true,
                  obscuringWidget: obscuringPinWidget(theme),
                  inputFormatters: [NumberInputFormatter],
                  autofocus: true,
                  errorTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.red),
                  defaultPinTheme: defaultPinTheme(theme),
                  validator: (_) => _validatePin(_ ?? ""),
                  onChanged: (p) {
                    setState2(() => _currentPass = p);
                  },
                  focusedPinTheme: focusedPinTheme(theme),
                  submittedPinTheme: submittedPinTheme(theme),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 32),
              ],
              Text(_i18n.get("password")),
              Pinput(
                obscureText: true,
                obscuringWidget: obscuringPinWidget(theme),
                inputFormatters: [NumberInputFormatter],
                autofocus: true,
                errorTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.red),
                defaultPinTheme: defaultPinTheme(theme),
                validator: (_) => _validatePin(_ ?? ""),
                onChanged: (p) {
                  setState2(() => _pass = p);
                },
                focusedPinTheme: focusedPinTheme(theme),
                submittedPinTheme: submittedPinTheme(theme),
              ),
              const SizedBox(height: 16),
              Text(_i18n.get("repeat_password")),
              Pinput(
                obscureText: true,
                obscuringWidget: obscuringPinWidget(theme),
                inputFormatters: [NumberInputFormatter],
                autofocus: true,
                errorTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.red),
                defaultPinTheme: defaultPinTheme(theme),
                validator: (_) => _validatePin(_ ?? ""),
                onChanged: (p) {
                  setState2(() => _repeatedPass = p);
                },
                focusedPinTheme: focusedPinTheme(theme),
                submittedPinTheme: submittedPinTheme(theme),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 40,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_i18n.get("cancel")),
              ),
            ),
            if (!checkCurrentPassword)
              SizedBox(
                height: 40,
                child: TextButton(
                  onPressed: _pass == _repeatedPass && _pass.isNotEmpty
                      ? () {
                          _authRepo.setLocalPassword(_pass);
                          setState(() {});
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(_i18n.get("save")),
                ),
              ),
            if (checkCurrentPassword)
              SizedBox(
                height: 40,
                child: TextButton(
                  onPressed: _pass == _repeatedPass &&
                          _pass.isNotEmpty &&
                          _currentPass.isNotEmpty
                      ? () {
                          if (_authRepo.localPasswordIsCorrect(_currentPass)) {
                            _authRepo.setLocalPassword(_pass);
                            setState(() {});
                            Navigator.of(context).pop();
                          } else {
                            // TODO(hasan): show error, https://gitlab.iais.co/deliver/wiki/-/issues/418
                          }
                        }
                      : null,
                  child: Text(_i18n.get("change")),
                ),
              ),
          ],
        );
      },
    );
  }

  String? _validatePin(String text) {
    if (text.isEmpty || text.length < 4) {
      return _i18n.get("not_valid_input");
    }
    return null;
  }
}
