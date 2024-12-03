import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/register/pages/login_vi_virtula_number_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/progressbar_wating.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/services/settings.dart';

class NewVirtualAccountPage extends StatefulWidget {
  @override
  State<NewVirtualAccountPage> createState() => _NewVirtualAccountPageState();
}

class _NewVirtualAccountPageState extends State<NewVirtualAccountPage> {
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final phone = "".obs;
  final _checked = false.obs;
  final _showPass = false.obs;
  final _showRepPass = false.obs;
  final _formKey = GlobalKey<FormState>();
  final ShakeWidgetController _shakeWidgetController = ShakeWidgetController();
  final _loading = false.obs;

  @override
  void initState() {
    _authRepo.getVirtualNumber().then((number) {
      if (number != null) {
        phone.value = number.toString();
      }
    });
    super.initState();
  }

  TextEditingController passwordController = TextEditingController();
  TextEditingController repPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = settings.introThemeData;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(_i18n.get("create_new_virtual_account")),
        ),
        body: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Center(
            child: FluidContainerWidget(
              showStandardContainer: true,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,

                width: isLargeWidth(MediaQuery.of(context).size.width)
                    ? 500
                    : null,
                // color: Colors.white,
                child: Obx(
                  () => phone.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: TextEditingController(
                                          text: phone.value),
                                      readOnly: true,
                                      style: const TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.phone),
                                        suffixIcon: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            saveToClipboard(phone.value);
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                          ),
                                        ),
                                        labelText: _i18n.get("virtual_number"),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      textAlign: TextAlign.center,
                                      obscureText: !_showPass.value,
                                      controller: passwordController,
                                      validator: (s) {
                                        if (s == null || s.isEmpty) {
                                          return _i18n.get("pas_not_empty");
                                        } else if (s.length < 7) {
                                          return _i18n
                                              .get("password_min_length");
                                        } else if (repPasswordController
                                                .text.isNotEmpty &&
                                            s != repPasswordController.text) {
                                          return _i18n
                                              .get("password_not_match");
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            saveToClipboard(
                                              passwordController.text,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                          ),
                                        ),
                                        prefixIcon: GestureDetector(
                                          onTap: () => _showPass.value =
                                              !_showPass.value,
                                          child: Icon(_showPass.value
                                              ? CupertinoIcons.eye_slash
                                              : CupertinoIcons.eye),
                                        ),
                                        labelText: _i18n.get("password"),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      textAlign: TextAlign.center,
                                      obscureText: !_showRepPass.value,
                                      controller: repPasswordController,
                                      validator: (repPass) {
                                        if (repPass == null ||
                                            repPass.isEmpty) {
                                          return _i18n.get("rep_pas_not_empty");
                                        } else if (repPass.length < 7) {
                                          return _i18n
                                              .get("password_min_length");
                                        } else if (repPass !=
                                            passwordController.text) {
                                          return _i18n
                                              .get("password_not_match");
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const SizedBox(
                                          width: 10,
                                        ),
                                        prefixIcon: GestureDetector(
                                          onTap: () => _showRepPass.value =
                                              !_showRepPass.value,
                                          child: Icon(_showRepPass.value
                                              ? CupertinoIcons.eye_slash
                                              : CupertinoIcons.eye),
                                        ),
                                        labelText: _i18n.get("repeat_password"),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ShakeWidget(
                                      controller: _shakeWidgetController,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Obx(
                                            () => Checkbox(
                                              value: _checked.value,
                                              onChanged: (value) => _checked
                                                  .value = !_checked.value,
                                            ),
                                          ),
                                          SizedBox(
                                            width: isLargeWidth(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width)
                                                ? 400
                                                : 220,
                                            child: Text(
                                              _i18n.get(
                                                "save_virtual_number_and_password",
                                              ),
                                              style: const TextStyle(
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: () async {
                                      if (!_loading.value) {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          if (_checked.value) {
                                            _loading.value = true;
                                            if (await _authRepo
                                                .saveUsernameAndPassword(
                                              username: int.parse(phone.value),
                                              password: passwordController.text,
                                            )) {
                                              _loading.value = false;
                                              unawaited(
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (c) {
                                                      return LoginViVirtualNumberPage(
                                                        phoneNumber:
                                                            phone.value,
                                                        password:
                                                            passwordController
                                                                .text,
                                                      );
                                                    },
                                                  ),
                                                  (r) => false,
                                                ),
                                              );
                                            } else {
                                              _loading.value = false;
                                              ToastDisplay.showToast(
                                                toastText:
                                                    _i18n.get("error_occurred"),
                                                toastContext: context,
                                              );
                                            }
                                          } else {
                                            await _shakeWidgetController
                                                .shake();
                                          }
                                        }
                                      }
                                    },
                                    child: SizedBox(
                                      width: 200,
                                      height: 50,
                                      child: _loading.value
                                          ? const SizedBox(
                                        width:25,
                                            height: 25,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.black26,
                                                ),
                                            ),
                                          )
                                          : Center(
                                              child: Text(
                                                _i18n.get("next"),
                                                style: const TextStyle(
                                                    fontSize: 17),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_i18n.get("load_information")),
                              const SizedBox(
                                width: 10,
                              ),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
