import 'dart:async';
import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/account.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AccountSettings extends StatefulWidget {
  final bool forceToSetUsernameAndName;

  const AccountSettings({Key? key, this.forceToSetUsernameAndName = false})
      : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final _i18n = GetIt.I.get<I18N>();
  final subject = BehaviorSubject<String>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  String _username = "";
  String _newUsername = "";
  String _email = "";
  String _lastName = "";
  String _firstName = "";
  String _lastUserName = "";
  Account? _account;
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  final BehaviorSubject<bool> _usernameIsAvailable =
      BehaviorSubject.seeded(true);

  final BehaviorSubject<String> _newAvatarPath = BehaviorSubject.seeded("");

  Future<void> attachFile() async {
    String? path;
    if (isWeb || isDesktop) {
      if (isLinux) {
        final typeGroup =
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
        cropAvatar(path);
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
                        child: ShareBoxGallery(
                          pop: () => Navigator.pop(context),
                          scrollController: scrollController,
                          setAvatar: cropAvatar,
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

  void cropAvatar(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return OpenImagePage(
            onEditEnd: (path) {
              imagePath = path;
              Navigator.pop(context);
              setAvatar(imagePath);
            },
            imagePath: imagePath,
          );
        },
      ),
    );
  }

  Future<void> setAvatar(String path) async {
    _newAvatarPath.add(path);
    await _avatarRepo.uploadAvatar(path, _authRepo.currentUserUid);
    _newAvatarPath.add("");
  }

  @override
  void initState() {
    try {
      _accountRepo.hasProfile();
      subject.stream
          .debounceTime(const Duration(milliseconds: 250))
          .listen((username) async {
        if (_usernameFormKey.currentState?.validate() ?? false) {
          if (_lastUserName != username) {
            _usernameIsAvailable
                .add(await _accountRepo.checkUserName(username));
          } else {
            _usernameIsAvailable.add(true);
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
        if (widget.forceToSetUsernameAndName) return false;
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: UltimateAppBar(
          child: AppBar(
            titleSpacing: 8,
            title: Column(
              children: [
                Text(_i18n.get("account_info")),
                if (widget.forceToSetUsernameAndName)
                  Text(
                    _i18n.get("should_set_username_and_name"),
                    style: theme.textTheme.headline6!.copyWith(fontSize: 10),
                  )
              ],
            ),
            leading: !widget.forceToSetUsernameAndName
                ? _routingService.backButtonLeading()
                : null,
          ),
        ),
        body: FluidContainerWidget(
          child: FutureBuilder<Account>(
            future: _accountRepo.getAccount(),
            builder: (c, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }
              _account = snapshot.data;
              if (snapshot.data!.userName != null) {
                _lastUserName = snapshot.data!.userName!;
              }
              return ListView(
                children: [
                  Section(
                    title: _i18n.get("avatar"),
                    children: [
                      NormalSettingsTitle(
                        child: Center(
                          child: StreamBuilder<String>(
                            stream: _newAvatarPath.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data!.isNotEmpty) {
                                return Stack(
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: isWeb
                                            ? Image.network(snapshot.data!)
                                                .image
                                            : Image.file(File(snapshot.data!))
                                                .image,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 45),
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
                                        color:
                                            Colors.grey[500]!.withOpacity(0.9),
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
                                      padding: const EdgeInsets.only(top: 35),
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
                                  Form(
                                    key: _usernameFormKey,
                                    child: TextFormField(
                                      minLines: 1,
                                      initialValue: snapshot.data!.userName,
                                      textInputAction: TextInputAction.send,
                                      onChanged: (str) {
                                        setState(() {
                                          _newUsername = str;
                                          _username = str;
                                          subject.add(str);
                                        });
                                      },
                                      validator: validateUsername,
                                      decoration: buildInputDecoration(
                                        _i18n.get("username"),
                                        isOptional: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  if (_newUsername.isEmpty)
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
                                  StreamBuilder<bool>(
                                    stream: _usernameIsAvailable.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null &&
                                          !snapshot.data!) {
                                        return Row(
                                          children: [
                                            Text(
                                              _i18n.get(
                                                "username_already_exist",
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    initialValue:
                                        snapshot.data!.firstName ?? "",
                                    minLines: 1,
                                    textInputAction: TextInputAction.send,
                                    onChanged: (str) {
                                      setState(() {
                                        _firstName = str;
                                      });
                                    },
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
                                    initialValue: snapshot.data!.lastName ?? "",
                                    minLines: 1,
                                    textInputAction: TextInputAction.send,
                                    onChanged: (str) {
                                      setState(() {
                                        _lastName = str;
                                      });
                                    },
                                    decoration: buildInputDecoration(
                                      _i18n.get("lastName"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    initialValue: snapshot.data!.email ?? "",
                                    minLines: 1,
                                    textInputAction: TextInputAction.send,
                                    onChanged: (str) {
                                      setState(() {
                                        _email = str;
                                      });
                                    },
                                    validator: validateEmail,
                                    decoration: buildInputDecoration(
                                      _i18n.get("email"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                child: Text(_i18n.get("save")),
                                onPressed: checkAndSend,
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

  InputDecoration buildInputDecoration(
    String label, {
    bool isOptional = false,
  }) {
    return InputDecoration(
      suffixIcon: isOptional
          ? const Padding(
              padding: EdgeInsets.only(top: 20, left: 25),
              child: Text(
                "*",
                style: TextStyle(color: Colors.red),
              ),
            )
          : const SizedBox.shrink(),
      labelText: label,
    );
  }

  String? validateFirstName(String? value) {
    if (value == null) return null;
    if (value.isEmpty) {
      return _i18n.get("firstname_not_empty");
    } else {
      return null;
    }
  }

  String? validateUsername(String? value) {
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      _usernameIsAvailable.add(true);
      return _i18n.get("username_not_empty");
    } else if (!regex.hasMatch(value)) {
      _usernameIsAvailable.add(true);
      return _i18n.get("username_not_valid");
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
        if (_usernameIsAvailable.value) {
          final setPrivateInfo = await _accountRepo.setAccountDetails(
            _username.isNotEmpty ? _username : _account!.userName,
            _firstName.isNotEmpty ? _firstName : _account!.firstName,
            _lastName.isNotEmpty ? _lastName : _account!.lastName,
            _email.isNotEmpty ? _email : _account!.email,
          );
          if (setPrivateInfo) {
            if (widget.forceToSetUsernameAndName) {
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
}
