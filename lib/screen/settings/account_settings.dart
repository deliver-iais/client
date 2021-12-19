import 'dart:io';
import 'dart:ui';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/account.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSettings extends StatefulWidget {
  final bool forceToSetUsernameAndName;

  const AccountSettings({Key? key, this.forceToSetUsernameAndName = true})
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
  late Account _account;
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  bool usernameIsAvailable = true;
  bool _userNameCorrect = false;

  final BehaviorSubject<bool> _uploadNewAvatar = BehaviorSubject.seeded(false);
  String _newAvatarPath = "";

  attachFile() async {
    String? path;
    if (isDesktop()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.media, allowMultiple: false);
      path = result!.files.first.path;
      if (path != null) {
        setAvatar(path);
      }
    } else {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              maxChildSize: 1,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                    color: Colors.white,
                    child: Stack(children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: ShareBoxGallery(
                          pop: () => Navigator.pop(context),
                          scrollController: scrollController,
                          setAvatar: (String filePath) async {
                            cropAvatar(filePath);
                          },
                          selectAvatar: true,
                          roomUid: _authRepo.currentUserUid,
                        ),
                      ),
                    ]));
              },
            );
          });
    }
  }

  void cropAvatar(String imagePath) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.square]
            : [
                CropAspectRatioPreset.square,
              ],
        cropStyle: CropStyle.rectangle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: _i18n.get("avatar"),
            toolbarColor: Colors.blueAccent,
            hideBottomControls: true,
            showCropGrid: false,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: _i18n.get("avatar"),
        ));
    if (croppedFile != null) {
      setAvatar(croppedFile.path);
    }
  }

  Future<void> setAvatar(String path) async {
    _uploadNewAvatar.add(true);
    _newAvatarPath = path;
    await _avatarRepo.uploadAvatar(File(path), _authRepo.currentUserUid);
    _uploadNewAvatar.add(false);
  }

  @override
  void initState() {
    _accountRepo.getProfile();
    subject.stream
        .debounceTime(const Duration(milliseconds: 250))
        .listen((username) async {
      _usernameFormKey.currentState?.validate();
      if (_userNameCorrect) {
        if (_lastUserName != username) {
          bool validUsername = await _accountRepo.checkUserName(username);
          setState(() {
            usernameIsAvailable = validUsername;
          });
        } else {
          setState(() {
            usernameIsAvailable = true;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.forceToSetUsernameAndName) return false;
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              titleSpacing: 8,
              title: Column(children: [
                Text(_i18n.get("account_info")),
                if (widget.forceToSetUsernameAndName)
                  Text(
                    _i18n.get("should_set_username_and_name"),
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontSize: 10),
                  )
              ]),
              leading: !widget.forceToSetUsernameAndName
                  ? _routingService.backButtonLeading(context)
                  : null,
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: FutureBuilder<Account>(
            future: _accountRepo.getAccount(),
            builder: (BuildContext c, AsyncSnapshot<Account> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return const SizedBox.shrink();
              }
              _account = snapshot.data!;
              if (snapshot.data!.userName != null) {
                _lastUserName = snapshot.data!.userName!;
              }
              return ListView(
                children: [
                  SettingsSection(title: _i18n.get("avatar"), tiles: [
                    NormalSettingsTitle(
                      child: Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 65,
                              backgroundImage:
                                  Image.file(File(_newAvatarPath)).image,
                              child: Center(
                                child: SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: StreamBuilder<bool>(
                                      stream: _uploadNewAvatar.stream,
                                      builder: (c, s) {
                                        if (s.hasData &&
                                            s.data != null &&
                                            s.data!) {
                                          return const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.blue),
                                            strokeWidth: 6.0,
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    )),
                              ),
                            ),
                            // Spacer(),
                            Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[500]!.withOpacity(0.4),
                              ),
                              child: IconButton(
                                color: Colors.white,
                                splashRadius: 40,
                                iconSize: 40,
                                icon: const Icon(
                                  Icons.add_a_photo,
                                ),
                                onPressed: () => attachFile(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                  SettingsSection(title: _i18n.get("account_info"), tiles: [
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
                                      style: TextStyle(
                                          color:
                                              ExtraTheme.of(context).textField),
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
                                          _i18n.get("username"), true)),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                _newUsername.isEmpty
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _i18n.get("username_helper"),
                                              textAlign: TextAlign.justify,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blueAccent),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                !usernameIsAvailable
                                    ? Row(
                                        children: [
                                          Text(
                                            _i18n.get("username_already_exist"),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.red),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  initialValue: snapshot.data!.firstName ?? "",
                                  minLines: 1,
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).textField),
                                  textInputAction: TextInputAction.send,
                                  onChanged: (str) {
                                    setState(() {
                                      _firstName = str;
                                    });
                                  },
                                  validator: validateFirstName,
                                  decoration: buildInputDecoration(
                                      _i18n.get("firstName"), true),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                    initialValue: snapshot.data!.lastName ?? "",
                                    minLines: 1,
                                    style: TextStyle(
                                        color:
                                            ExtraTheme.of(context).textField),
                                    textInputAction: TextInputAction.send,
                                    onChanged: (str) {
                                      setState(() {
                                        _lastName = str;
                                      });
                                    },
                                    decoration: buildInputDecoration(
                                        _i18n.get("lastName"), false)),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                    initialValue: snapshot.data!.email ?? "",
                                    minLines: 1,
                                    style: TextStyle(
                                        color:
                                            ExtraTheme.of(context).textField),
                                    textInputAction: TextInputAction.send,
                                    onChanged: (str) {
                                      setState(() {
                                        _email = str;
                                      });
                                    },
                                    validator: validateEmail,
                                    decoration: buildInputDecoration(
                                        _i18n.get("email"), false)),
                              ],
                            )),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text(_i18n.get("save")),
                            onPressed: () async {
                              checkAndSend();
                            },
                          ),
                        )
                      ],
                    ))
                  ])
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(label, bool isOptional) {
    return InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
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
        labelStyle: const TextStyle(color: Colors.blue));
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
    Pattern? pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp? regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      setState(() {
        _userNameCorrect = false;
        usernameIsAvailable = true;
      });
      return _i18n.get("username_not_empty");
    } else if (!regex.hasMatch(value)) {
      setState(() {
        _userNameCorrect = false;
        usernameIsAvailable = true;
      });
      return _i18n.get("username_length");
    } else {
      setState(() {
        _userNameCorrect = true;
      });
    }
    return null;
  }

  String? validateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      return null;
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("email_not_valid");
    }
    return null;
  }

  checkAndSend() async {
    bool checkUserName = _usernameFormKey.currentState?.validate() ?? false;
    if (checkUserName) {
      bool isValidated = _formKey.currentState?.validate() ?? false;
      if (isValidated) {
        if (usernameIsAvailable) {
          bool setPrivateInfo = await _accountRepo.setAccountDetails(
              _username.isNotEmpty ? _username : _account.userName,
              _firstName.isNotEmpty ? _firstName : _account.firstName,
              _lastName.isNotEmpty ? _lastName : _account.lastName,
              _email.isNotEmpty ? _email : _account.email);
          if (setPrivateInfo) {
            _routingService.pop();
          }
        }
      }
    }
  }
}
