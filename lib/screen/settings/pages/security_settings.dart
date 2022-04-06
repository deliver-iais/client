import 'package:deliver/box/dao/shared_dao.dart';
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
  final _shareDao = GetIt.I.get<SharedDao>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _pasFormKey = GlobalKey<FormState>();
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
              title: _i18n.get("security"),
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
                SettingsTile.switchTile(
                  title: _i18n.get("two_step_verification"),
                  leading: const Icon(CupertinoIcons.lock_shield),
                  switchValue: _authRepo.isTwoStepVerificationEnabled(),
                  onToggle: (enabled) async {
                    if (enabled) {
                      final email = await _shareDao.get(SHARED_DAO_EMAIL);
                      if (email != null && email.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return setPassword(email);
                          },
                        );
                      } else {
                        showDialog(
                            context: context,
                            builder: (c) {
                              return AlertDialog(
                                content: Text(_i18n.get("need_to_set_email")),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(c);
                                        _routingService.openAccountSettings();
                                      },
                                      child: Text(_i18n.get("go_setting")))
                                ],
                              );
                            });
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return disableTwoStepVerification();
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
            Form(
              key: _pasFormKey,
              child: TextFormField(
                controller: _textController,
                validator: (pas) {
                  if (pas == null || pas.isEmpty) {
                    return _i18n.get("insert_password");
                  } else if (!_authRepo.passwordIsCorrect(pas)) {
                    return _i18n.get("password_not_correct");
                  }
                },
                obscureText: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _i18n.get("current_password"),
                ),
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
                if (_pasFormKey.currentState!.validate()) {
                  await _accountRepo.disableTwoStepVerification();
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: Text(_i18n.get("disable")),
            ),
          ),
        ],
      ),
    );
  }

  Widget setPassword(String email) {
    final _pasController = TextEditingController();
    final _repPasController = TextEditingController();
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
                if (_pasFormKey.currentState!.validate() &&
                    _repPasFormKey.currentState!.validate()) {
                  final isSet = await _accountRepo
                      .enableTwoStepVerification(_repPasController.text);
                  if (isSet) {
                    ToastDisplay.showToast(
                      toastContext: c,
                      toastText: _i18n.get("two_step_verification_active"),
                    );
                    setState(() {});
                    Navigator.of(context).pop();

                  } else {
                    ToastDisplay.showToast(
                        toastContext: c,
                        toastText: _i18n.get("error_occurred"));
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
                    if (s == null || s.isEmpty) {
                      return _i18n.get("pas_not_empty");
                    } else if (_repPasController.text.isNotEmpty &&
                        s != _repPasController.text) {
                      return _i18n.get("password_not_match");
                    }
                  },
                  decoration: InputDecoration(
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
                  },
                  decoration: InputDecoration(
                    hintText: _i18n.get("repeat_password"),
                  ),
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
                    helperText: _i18n.get("email_for_two_step")),
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
