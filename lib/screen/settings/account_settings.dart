import 'dart:io';
import 'dart:ui';

import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/screen/settings/settings_page.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/widgets/fluid_container.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSettings extends StatefulWidget {
  final bool forceToSetUsernameAndName;

  AccountSettings({Key key, this.forceToSetUsernameAndName = true})
      : super(key: key);

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  I18N _i18n;
  final subject = new BehaviorSubject<String>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  String _username = "";
  String _newUsername = "";
  String _email = "";
  String _lastName = "";
  String _firstName = "";
  String _lastUserName;
  Account _account;
  final _formKey = GlobalKey<FormState>();
  final _usernameFormKey = GlobalKey<FormState>();
  bool usernameIsAvailable = true;
  bool _userNameCorrect = false;

  bool _uploadNewAvatar = false;
  String _newAvatarPath;

  attachFile() async {
    String path;
    if (isDesktop()) {
      final typeGroup =
          XTypeGroup(label: 'images', extensions: SUPPORTED_IMAGE_EXTENSIONS);
      final result = await openFile(acceptedTypeGroups: [typeGroup]);
      path = result.path;
    } else {
      var result = await ImagePicker().getImage(source: ImageSource.gallery);
      path = result.path;
    }
    if (path != null) {
      setState(() {
        _newAvatarPath = path;
        _uploadNewAvatar = true;
      });
      await _avatarRepo.uploadAvatar(File(path), _authRepo.currentUserUid);
      setState(() {
        _uploadNewAvatar = false;
      });
    }
  }

  @override
  void initState() {
    _accountRepo.getProfile();
    subject.stream
        .debounceTime(Duration(milliseconds: 250))
        .listen((username) async {
      _usernameFormKey?.currentState?.validate();
      if (_userNameCorrect) {
        if (_lastUserName != username) {
          bool validUsername = await _accountRepo.checkUserName(username);
          setState(() {
            usernameIsAvailable = validUsername;
          });
        } else if (_lastUserName != null) {
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
    _i18n = I18N.of(context);
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
                        .headline6
                        .copyWith(fontSize: 10),
                  )
              ]),
              leading: !widget.forceToSetUsernameAndName
                  ? _routingService.backButtonLeading()
                  : null,
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: FutureBuilder<Account>(
            future: _accountRepo.getAccount(),
            builder: (BuildContext c, AsyncSnapshot<Account> snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return SizedBox.shrink();
              }
              _account = snapshot.data;
              _lastUserName = snapshot.data.userName;
              return ListView(
                children: [
                  SettingsSection(title: _i18n.get("avatar"), tiles: [
                    NormalSettingsTitle(
                      child: Center(
                        child: Stack(
                          children: [
                            _newAvatarPath != null
                                ? CircleAvatar(
                                    radius: 65,
                                    backgroundImage:
                                        Image.file(File(_newAvatarPath)).image,
                                    child: Center(
                                      child: SizedBox(
                                          height: 50.0,
                                          width: 50.0,
                                          child: _uploadNewAvatar
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          Colors.blue),
                                                  strokeWidth: 6.0,
                                                )
                                              : SizedBox.shrink()),
                                    ),
                                  )
                                : CircleAvatarWidget(
                                    _authRepo.currentUserUid,
                                    65,
                                    showAsStreamOfAvatar: true,
                                  ),
                            // Spacer(),
                            Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[500].withOpacity(0.4),
                              ),
                              child: IconButton(
                                color: Colors.white,
                                splashRadius: 40,
                                iconSize: 40,
                                icon: Icon(
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
                                      initialValue: snapshot.data.userName,
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
                                SizedBox(
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
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blueAccent),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                !usernameIsAvailable
                                    ? Row(
                                        children: [
                                          Text(
                                            _i18n.get("username_already_exist"),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  initialValue: snapshot.data.firstName ?? "",
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
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                    initialValue: snapshot.data.lastName ?? "",
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
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                    initialValue: snapshot.data.email ?? "",
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
                        SizedBox(height: 8),
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
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: isOptional
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 25),
                child: Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : SizedBox.shrink(),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue));
  }

  String validateFirstName(String value) {
    if (value.isEmpty) {
      return _i18n.get("firstname_not_empty");
    } else {
      return null;
    }
  }

  String validateUsername(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
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

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return null;
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("email_not_valid");
    }
    return null;
  }

  checkAndSend() async {
    bool checkUserName = _usernameFormKey?.currentState?.validate() ?? false;
    if (checkUserName) {
      bool isValidated = _formKey?.currentState?.validate() ?? false;
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
