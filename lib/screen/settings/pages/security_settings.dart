import 'package:deliver/box/account.dart';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';

import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  _SecuritySettingsPageState createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _pasFormKey = GlobalKey<FormState>();
  final _newPassFormKey = GlobalKey<FormState>();
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
            Section(
              title: _i18n.get("lock_app"),
              children: [
                SettingsTile.switchTile(
                  title: _i18n.get("enable_local_lock"),
                  leading: const Icon(CupertinoIcons.lock),
                  switchValue: _authRepo.isLocalLockEnabled(),
                  onToggle: (enabled) {
                    if (enabled) {
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
                    leading: const Icon(CupertinoIcons.bandage),
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
                      if (accountData.hasData) {
                        return SettingsTile.switchTile(
                          title: _i18n.get("two_step_verification"),
                          leading: const Icon(CupertinoIcons.lock_shield),
                          switchValue: accountData.data!.passwordProtected,
                          onToggle: (enabled) async {
                            if (enabled) {
                              if (accountData.data!.email != null &&
                                  accountData.data!.email!.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return enableTwoStepVerification(
                                      accountData.data!.email!,
                                    );
                                  },
                                ).ignore();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (c) {
                                    return AlertDialog(
                                      content:
                                          Text(_i18n.get("need_to_set_email")),
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
                  FutureBuilder<bool>(
                    future: _accountRepo.isTwoStepVerificationEnabled(),
                    builder: (c, snapshot) {
                      if (snapshot.hasData && snapshot.data!) {
                        return SettingsTile(
                          title:
                              _i18n.get("edit_two_step_verification_password"),
                          leading: const Icon(CupertinoIcons.bandage),
                          onPressed: (c) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _editTwoStepVerificationPassword(
                                  context,
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

  Widget _editTwoStepVerificationPassword(BuildContext context) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _repNewPasswordController = TextEditingController();
    final _hintPassController = TextEditingController();
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            "assets/animations/lock.json",
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
          Form(
            key: _pasFormKey,
            child: TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              validator: (s) {
                if (s == null || s.isEmpty) {
                  return _i18n.get("insert_current_password");
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _i18n.get("current_password"),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Form(
            key: _newPassFormKey,
            child: TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              validator: (s) {
                if (s == null || s.isEmpty) {
                  return _i18n.get("insert_new_password");
                } else if (_repNewPasswordController.text.isNotEmpty &&
                    s != _repNewPasswordController.text) {
                  return _i18n.get("password_not_match");
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _i18n.get("new_password"),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _repPasFormKey,
            child: TextFormField(
              controller: _repNewPasswordController,
              obscureText: true,
              validator: (s) {
                if (s == null || s.isEmpty) {
                  return _i18n.get("repeat_password");
                } else if (_newPasswordController.text.isNotEmpty &&
                    s != _newPasswordController.text) {
                  return _i18n.get("password_not_match");
                }
                return null;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: _i18n.get("repeat_new_password"),
              ),
            ),
          ),
          TextFormField(
            controller: _hintPassController,
            decoration: InputDecoration(
              hintText: _i18n.get("password_hint"),
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
              if (_pasFormKey.currentState!.validate() &&
                  _newPassFormKey.currentState!.validate() &&
                  _repPasFormKey.currentState!.validate()) {
                if (await _accountRepo.changeTwoStepVerificationPassword(
                  currentPassword: _currentPasswordController.text,
                  newPassword: _newPasswordController.text,
                )) {
                  ToastDisplay.showToast(
                    toastContext: context,
                    toastText: _i18n.get("password_changed"),
                  );
                  Navigator.of(context).pop();
                } else {
                  //todo
                }
              }
            },
            child: Text(_i18n.get("change")),
          ),
        ),
      ],
    );
  }

  Widget disableLocalPassword() {
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
        content: TextField(
          onChanged: (p) => setState2(() => _currentPass = p),
          obscureText: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: _i18n.get("current_password"),
          ),
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
                        _authRepo.setLocalPassword("");
                        setState(() {});
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
      ),
    );
  }

  Widget disableTwoStepVerification() {
    final _textController = TextEditingController();
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/animations/lock.json",
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
              controller: _textController,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _i18n.get("current_password"),
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
                    .disableTwoStepVerification(_textController.text)) {
                  setState(() {});
                  Navigator.of(context).pop();
                } else {
                  ToastDisplay.showToast(
                    toastContext: context,
                    toastText: _i18n.get("incorrect_password"),
                  );
                }
              },
              child: Text(_i18n.get("disable")),
            ),
          ),
        ],
      ),
    );
  }

  Widget enableTwoStepVerification(String email) {
    final _pasController = TextEditingController();
    final _repPasController = TextEditingController();
    final _hintPasController = TextEditingController();
    return StatefulBuilder(
      builder: (c, set) {
        return AlertDialog(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(c);
              },
              child: Text(_i18n.get("cancel")),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigatorState = Navigator.of(c);
                if (_pasFormKey.currentState!.validate() &&
                    _repPasFormKey.currentState!.validate()) {
                  final isSet = await _accountRepo.updatePassword(
                    newPassword: _pasController.text,
                    passwordHint: _hintPasController.text,
                  );
                  if (isSet) {
                    ToastDisplay.showToast(
                      toastContext: c,
                      toastText: _i18n.get("two_step_verification_active"),
                    );

                    setState(() {});
                    navigatorState.pop();
                  } else {
                    ToastDisplay.showToast(
                      toastContext: c,
                      toastText: _i18n.get("error_occurred"),
                    );
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
              Lottie.asset(
                "assets/animations/lock.json",
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
              Form(
                key: _pasFormKey,
                child: TextFormField(
                  controller: _pasController,
                  obscureText: true,
                  validator: (s) {
                    const Pattern pattern =
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
                    final regex = RegExp(pattern.toString());
                    if (s == null || s.isEmpty) {
                      return _i18n.get("pas_not_empty");
                    } else if (!regex.hasMatch(s)) {
                      return _i18n.get("password_not_valid");
                    } else if (_repPasController.text.isNotEmpty &&
                        s != _repPasController.text) {
                      return _i18n.get("password_not_match");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    helperText: _i18n.get("password_helper"),
                    hintText: _i18n.get("password"),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                key: _repPasFormKey,
                child: TextFormField(
                  controller: _repPasController,
                  obscureText: true,
                  validator: (repPass) {
                    if (repPass == null || repPass.isEmpty) {
                      return _i18n.get("rep_pas_not_empty");
                    } else if (repPass != _pasController.text) {
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
                controller: _hintPasController,
                decoration: InputDecoration(
                  hintText: _i18n.get("password_hint"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                _i18n.get("two_step_verification_des"),
                style: Theme.of(context).textTheme.caption,
              ),
              const SizedBox(
                height: 40,
              ),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: email),
                decoration: InputDecoration(
                  labelText: _i18n.get("recovery_email"),
                  helperText: _i18n.get("email_for_two_step"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget setLocalPassword() {
    final checkCurrentPassword = _authRepo.isLocalLockEnabled();
    return StatefulBuilder(
      builder: (context, setState2) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (checkCurrentPassword)
              TextField(
                onChanged: (p) => setState2(() => _currentPass = p),
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _i18n.get("current_password"),
                ),
              ),
            if (checkCurrentPassword) const SizedBox(height: 40),
            TextField(
              onChanged: (p) => setState2(() => _pass = p),
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _i18n.get("password"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (p) => setState2(() => _repeatedPass = p),
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _i18n.get("repeat_password"),
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
      ),
    );
  }
}
