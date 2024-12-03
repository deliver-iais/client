import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/register/pages/new_virtual_account_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/progressbar_wating.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class LoginViVirtualNumberPage extends StatefulWidget {
  String? phoneNumber;
  String? password;

  LoginViVirtualNumberPage({this.phoneNumber, this.password});

  @override
  State<LoginViVirtualNumberPage> createState() =>
      _LoginViVirtualNumberPageState();
}

class _LoginViVirtualNumberPageState extends State<LoginViVirtualNumberPage> {
  final _i18n = GetIt.I.get<I18N>();

  final _authRepo = GetIt.I.get<AuthRepo>();

  final _showPass = false.obs;
  final _loading = false.obs;
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    phoneController = TextEditingController(text: widget.phoneNumber);
    passwordController = TextEditingController(text: widget.password);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = settings.introThemeData;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(_i18n.get("login_vi_virtual_number")),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width:
                  isLargeWidth(MediaQuery.of(context).size.width) ? 500 : null,
              child: FluidContainerWidget(
                showStandardContainer: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 50,
                              ),
                              TextFormField(
                                validator: (_) {
                                  if (_ == null || _.isEmpty || _.length < 8) {
                                    return _i18n.get("invalid_mobile_number");
                                  }
                                  return null;
                                },
                                controller: phoneController,
                                textAlign: TextAlign.center,
                                maxLength: 8,
                                inputFormatters: [NumberInputFormatter],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: _i18n.get("virtual_number"),
                                  // hintText: "12345678",
                                  prefixIcon: const Icon(Icons.phone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Obx(
                                () => TextFormField(
                                  validator: (_) {
                                    if (_ == null ||
                                        _.isEmpty ||
                                        _.length < 7) {
                                      return _i18n.get("invalid_password");
                                    }
                                    return null;
                                  },
                                  controller: passwordController,
                                  textAlign: TextAlign.center,
                                  obscureText: !_showPass.value,
                                  decoration: InputDecoration(
                                    prefixIcon: GestureDetector(
                                      onTap: () =>
                                          _showPass.value = !_showPass.value,
                                      child: Icon(_showPass.value
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    labelText: _i18n.get("password"),
                                    hintText: "",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) {
                                          return NewVirtualAccountPage();
                                        },
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Icon(Icons.add),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(_i18n.get("create_virtual_account")),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: Container(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.canvasColor,
                            ),
                            onPressed: () async {
                              try {
                                if (!_loading.value) {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _loading.value = true;
                                    if (await _authRepo.loginByUsername(
                                      phone: int.parse(phoneController.text),
                                      password: passwordController.text,
                                    )) {
                                      _loading.value = false;
                                      await Navigator.of(context)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (c) => const HomePage(),
                                        ),
                                        (r) => false,
                                      );
                                    } else {
                                      _loading.value = false;
                                      ToastDisplay.showToast(
                                        toastText: _i18n.get("error_occurred"),
                                        toastContext: context,
                                      );
                                    }
                                  }
                                }
                              } catch (e) {
                                ToastDisplay.showToast(
                                  toastText: _i18n.get("error_occurred"),
                                  toastContext: context,
                                );
                              }
                            },
                            child: SizedBox(
                              width: 200,
                              height: 50,
                              child: Center(
                                child: _loading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.black26,
                                      )
                                    : Text(
                                        _i18n.get("login"),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
