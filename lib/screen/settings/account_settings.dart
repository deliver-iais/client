import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery_box.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AccountSettings extends StatefulWidget {
  final bool forceToSetName;

  const AccountSettings({super.key, this.forceToSetName = false});

  @override
  AccountSettingsState createState() => AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  final _i18n = GetIt.I.get<I18N>();
  final _idIsIsAvailableChecker = BehaviorSubject<String>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _usernameTextController = TextEditingController();
  final _firstnameTextController = TextEditingController();
  final _lastnameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  Account _account = Account();
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  bool _usernameIsAvailable = true;

  final BehaviorSubject<String> _newAvatarPath = BehaviorSubject.seeded("");

  Future<void> attachFile() async {
    String? path;
    if (isDesktopNativeOrWeb) {
      if (isLinuxNative) {
        const typeGroup =
            XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'gif']);
        final file = await openFile(
          acceptedTypeGroups: [typeGroup],
        );
        if (file != null) {
          path = file.path;
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: true);
        if (result != null && result.files.isNotEmpty) {
          path = isWeb
              ? Uri.dataFromBytes(result.files.first.bytes!.toList()).toString()
              : result.files.first.path;
        }
      }

      if (path != null) {
        viewSelectedImage(path);
      }
    } else {
      unawaited(
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: GalleryBox.setAvatar(
                          scrollController: scrollController,
                          onAvatarSelected: (path) => viewSelectedImage(path),
                          roomUid: _authRepo.currentUserUid,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  void viewSelectedImage(String imagePath) => _routingService.openViewImagePage(
        imagePath: imagePath,
        onEditEnd: (path) {
          Navigator.pop(context);
          setAvatar(path);
        },
      );

  Future<void> setAvatar(String path) async {
    _newAvatarPath.add(path);
    await _avatarRepo.uploadAvatar(path, _authRepo.currentUserUid);
    _newAvatarPath.add("");
  }

  @override
  void initState() {
    try {
      _accountRepo.hasProfile();
      _idIsIsAvailableChecker
          .debounceTime(const Duration(milliseconds: 250))
          .listen((username) async {
        _usernameIsAvailable = true;
        if ((_usernameFormKey.currentState?.validate() ?? false) &&
            (_account.username == null ||
                _account.username != _usernameTextController.text)) {
          _usernameIsAvailable = await _accountRepo.idIsAvailable(username);
          if (!_usernameIsAvailable) {
            _usernameFormKey.currentState?.validate();
          }
        }
      });
      super.initState();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (widget.forceToSetName) return false;
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: BlurredPreferredSizedWidget(
          child: AppBar(
            titleSpacing: 8,
            title: Column(
              children: [
                Text(_i18n.get("account_info")),
                if (widget.forceToSetName)
                  Text(
                    _i18n.get("should_set_username_and_name"),
                    style: theme.textTheme.titleLarge!.copyWith(fontSize: 10),
                  )
              ],
            ),
            leading: !widget.forceToSetName
                ? _routingService.backButtonLeading()
                : null,
          ),
        ),
        body: FluidContainerWidget(
          child: FutureBuilder<Account?>(
            future: _accountRepo.getAccount(),
            builder: (c, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data != null) {
                _account = snapshot.data!;
              }
              _usernameTextController.text = _account.username ?? "";
              _firstnameTextController.text = _account.firstname ?? "";
              _lastnameTextController.text = _account.lastname ?? "";
              _descriptionTextController.text = _account.description ?? "";
              _emailTextController.text = _account.email ?? "";

              return ListView(
                children: [
                  Section(
                    title: _i18n.get("avatar"),
                    children: [
                      NormalSettingsTitle(
                        child: Center(
                          child: StreamBuilder<String>(
                            stream: _newAvatarPath,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data!.isNotEmpty) {
                                return Stack(
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage:
                                            snapshot.data!.imageProvider(),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsetsDirectional.only(top: 45),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 6.0,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                              return Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 130,
                                      width: 130,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[500]!
                                            .withOpacity(0.9),
                                      ),
                                      child: CircleAvatarWidget(
                                        _authRepo.currentUserUid,
                                        130,
                                        hideName: true,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.only(top: 35),
                                      child: IconButton(
                                        color: Colors.white,
                                        splashRadius: 40,
                                        iconSize: 50,
                                        icon: const Icon(
                                          Icons.add_a_photo,
                                        ),
                                        onPressed: () => attachFile(),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Section(
                    title: _i18n.get("account_info"),
                    children: [
                      NormalSettingsTitle(
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    minLines: 1,
                                    controller: _firstnameTextController,
                                    textInputAction: TextInputAction.send,
                                    validator: validateFirstName,
                                    decoration: buildInputDecoration(
                                      _i18n.get("firstName"),
                                      isOptional: true,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    minLines: 1,
                                    controller: _lastnameTextController,
                                    textInputAction: TextInputAction.send,
                                    decoration: buildInputDecoration(
                                      _i18n.get("lastName"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Autocomplete<String>(
                                    optionsBuilder: (textEditingValue) =>
                                        _getUsernameSuggestion(
                                      textEditingValue.text,
                                    ),
                                    initialValue: TextEditingValue(
                                      text: _usernameTextController.text,
                                    ),
                                    onSelected: (selection) {
                                      _usernameTextController.text =
                                          selection;
                                      _usernameFormKey.currentState
                                          ?.validate();
                                    },
                                    fieldViewBuilder: (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      return GestureDetector(
                                        onTap: () {
                                          onFieldSubmitted();
                                        },
                                        child: Column(
                                          children: [
                                            Form(
                                              key: _usernameFormKey,
                                              child: TextFormField(
                                                minLines: 1,
                                                focusNode: focusNode,
                                                controller:
                                                    textEditingController,
                                                textInputAction:
                                                    TextInputAction.send,
                                                onChanged: (str) {
                                                  _usernameTextController
                                                      .text = str;
                                                  _idIsIsAvailableChecker
                                                      .add(str);
                                                },
                                                maxLength: 20,
                                                validator: validateUsername,
                                                decoration:
                                                    buildInputDecoration(
                                                  _i18n.get(
                                                    "username",
                                                  ),
                                                  hintText: "alice_bob",
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    optionsViewBuilder: (
                                      con,
                                      void Function(String) onSelected,
                                      options,
                                    ) {
                                      return Stack(
                                        children: [
                                          Material(
                                            child: Container(
                                              color: CupertinoColors
                                                  .inactiveGray
                                                  .withOpacity(0.2),
                                              child: Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: options.map((opt) {
                                                  return InkWell(
                                                    onTap: () {
                                                      onSelected(opt);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 60,
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(opt),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _i18n.get("username_helper"),
                                          textAlign: TextAlign.justify,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (TWO_STEP_VERIFICATION_IS_AVAILABLE)
                                    TextFormField(
                                      minLines: 1,
                                      controller: _emailTextController,
                                      textInputAction: TextInputAction.send,
                                      validator: validateEmail,
                                      decoration: InputDecoration(
                                        labelText: _i18n.get("email"),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    minLines: 1,
                                    controller: _descriptionTextController,
                                    textInputAction: TextInputAction.send,
                                    decoration: InputDecoration(
                                      labelText: _i18n.get("description"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: checkAndSend,
                                child: Text(_i18n.get("save")),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getUsernameSuggestion(String input) async {
    final regex = RegExp(r'^[\u0600-\u06FF\s]+$');
    var name = _firstnameTextController.text;
    name = regex.hasMatch(name)
        ? ""
        : name
            .toLowerCase()
            .replaceAll(RegExp(r"[^\s\w]"), "")
            .replaceAll(" ", "");

    var lastName = _lastnameTextController.text;
    lastName = regex.hasMatch(lastName)
        ? ""
        : lastName
            .toLowerCase()
            .replaceAll(RegExp(r"[^\s\w]"), "")
            .replaceAll(" ", "");

    if (name.isEmpty && lastName.isEmpty) return [];

    final u1 = name + lastName;
    final u2 = "${name}_$lastName";
    final u3 = name.isEmpty ? lastName : name;
    var suggestion = <String>[u1, u2, u3];
    if (name.isNotEmpty && lastName.isNotEmpty) {
      suggestion.add("${name.substring(0, 1)}_$lastName");
    }
    suggestion = suggestion
        .map<String>(
          (e) => e.length > 20 ? e.substring(0, 20).trim() : e.trim(),
        )
        .where((element) => element.length > 4 && element.contains(input))
        .toList();

    final res = <String>[];
    for (final element in suggestion) {
      if ((_account.username != null && _account.username == element) ||
          await _accountRepo.idIsAvailable(element)) {
        res.add(element);
      }
    }
    return res;
  }

  InputDecoration buildInputDecoration(
    String label, {
    bool isOptional = false,
    String hintText = "",
  }) {
    return InputDecoration(
      suffixIcon: isOptional
          ? const Padding(
              padding: EdgeInsetsDirectional.only(top: 20, start: 25),
              child: Text(
                "*",
                style: TextStyle(color: Colors.red),
              ),
            )
          : const SizedBox.shrink(),
      labelText: label,
      hintText: hintText,
    );
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return _i18n.get("firstname_not_empty");
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return null;
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value.contains(".")) {
      return _i18n.get("cannot_contain_dots");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("username_not_valid");
    }
    if (!_usernameIsAvailable) {
      return _i18n.get(
        "username_already_exist",
      );
    }
    return null;
  }

  String? validateEmail(String? value) {
    const Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      return null;
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("email_not_valid");
    }
    return null;
  }

  Future<void> checkAndSend() async {
    final navigatorState = Navigator.of(context);
    final checkUserName = _usernameFormKey.currentState?.validate() ?? false;
    if (checkUserName) {
      final isValidated = _formKey.currentState?.validate() ?? false;
      if (isValidated) {
        var setPrivateInfo = await _accountRepo.setAccountDetails(
          username: _usernameTextController.text,
          firstname: _firstnameTextController.text,
          lastname: _lastnameTextController.text,
          description: _descriptionTextController.text,
        );
        if (_emailTextController.text.isNotEmpty &&
            _emailTextController.text != _account.email) {
          try {
            final res =
                await _accountRepo.updateEmail(_emailTextController.text);
            if (!res) {
              if (context.mounted) {
                ToastDisplay.showToast(
                  toastContext: context,
                  toastText: _i18n.get("email_not_verified"),
                );
              }

              setPrivateInfo = false;
            }
          } catch (e) {
            if (context.mounted) {
              ToastDisplay.showToast(
                toastContext: context,
                toastText: _i18n.get("error_occurred_in_save_email"),
              );
            }
            setPrivateInfo = false;
          }
        }

        if (setPrivateInfo) {
          if (widget.forceToSetName) {
            navigatorState.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (c) {
                  return const HomePage();
                },
              ),
              (r) => false,
            ).ignore();
          } else {
            _routingService.pop();
          }
        }
      }
    }
  }
}
