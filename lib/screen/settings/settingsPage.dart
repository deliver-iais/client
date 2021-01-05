import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/services/firebase_services.dart';

import 'package:deliver_flutter/services/routing_service.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profile_avatar_card.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:file_chooser/file_chooser.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _uxService = GetIt.I.get<UxService>();

  final _accountRepo = GetIt.I.get<AccountRepo>();

  final _avatarRepo = GetIt.I.get<AvatarRepo>();

  final _routingService = GetIt.I.get<RoutingService>();

  bool _uploadNewAvatar = false;
  String _newAvatarPath = "";

  bool _getTheme() {
    if (_uxService.theme == DarkTheme) {
      return true;
    } else {
      return false;
    }
  }

  void _changeLanguage(Language language) {
    GetIt.I.get<UxService>().changeLanguage(language);
  }

  attachFile() async {
    String path;
    if (isDesktop()) {
      final result = await showOpenPanel(
          allowsMultipleSelection: false,
          allowedFileTypes: [
            FileTypeFilterGroup(
                fileExtensions: ['png', 'jpg', 'jpeg', 'gif'], label: "image")
          ]);
      if (result.paths.isNotEmpty) {
        path = result.paths.first;
      }
    } else {
      var result = await ImagePicker().getImage(source: ImageSource.gallery);
      path = result.path;
    }
    if (path != null) {
      setState(() {
        _newAvatarPath = path;
        _uploadNewAvatar = true;
      });
      await _avatarRepo.uploadAvatar(File(path), _accountRepo.currentUserUid);
      setState(() {
        _uploadNewAvatar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                appLocalization.getTraslateValue("settings"),
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            leading: _routingService.backButtonLeading()),
        body: FluidContainerWidget(
          child: ListView(children: [
            ProfileAvatarCard(
              uploadNewAvatar: _uploadNewAvatar,
              newAvatarPath: _newAvatarPath,
              uid: _accountRepo.currentUserUid,
              buttons: [
                MaterialButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: () {
                    attachFile();
                  },
                  shape: CircleBorder(),
                  child: Icon(Icons.add_a_photo),
                  padding: const EdgeInsets.all(20),
                ),
                MaterialButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: () {
                    _routingService
                        .openRoom(_accountRepo.currentUserUid.asString());
                  },
                  shape: CircleBorder(),
                  child: Icon(Icons.bookmark),
                  padding: const EdgeInsets.all(20),
                ),
                Tooltip(
                  message: appLocalization.getTraslateValue("Log_out"),
                  child: MaterialButton(
                    color: Theme.of(context).errorColor,
                    onPressed: () {
                      _routingService.logout(context);
                    },
                    shape: CircleBorder(),
                    child: Icon(Icons.exit_to_app),
                    padding: const EdgeInsets.all(20),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            settingsRow(context,
                iconData: Icons.person,
                title: appLocalization.getTraslateValue("username"),
                child: Row(
                  children: <Widget>[
                    FutureBuilder<Account>(
                      future: _accountRepo.getAccount(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Account> snapshot) {
                        if (snapshot.data != null) {
                          return Text(
                            snapshot.data.userName ?? "",
                            style: TextStyle(
                                color: ExtraTheme.of(context).text,
                                fontSize: 13),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.navigate_next),
                        onPressed: () {
                          _routingService.openAccountSettings();
                        }),
                  ],
                )),
            settingsRow(
              context,
              iconData: Icons.person,
              title: appLocalization.getTraslateValue("phone"),
              child: Row(
                children: <Widget>[
                  FutureBuilder<Account>(
                    future: _accountRepo.getAccount(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Account> snapshot) {
                      if (snapshot.data != null) {
                        return Text(
                          snapshot.data.phoneNumber,
                          style: TextStyle(
                              color: ExtraTheme.of(context).text, fontSize: 13),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.navigate_next),
                      onPressed: () {
                        _routingService.openAccountSettings();
                      }),
                ],
              ),
            ),
            settingsRow(
              context,
              iconData: Icons.brightness_2,
              title: appLocalization.getTraslateValue("darkMode"),
              child: Switch(
                value: _getTheme(),
                onChanged: (newThemMode) {
                  _uxService.toggleTheme();
                },
              ),
            ),
            settingsRow(context,
                iconData: Icons.notifications_active,
                title: appLocalization.getTraslateValue("notification"),
                child: FutureBuilder<String>(
                    future: _accountRepo.notification,
                    builder: (c, notif) {
                      if (notif.hasData && notif.data != null) {
                        bool notification =
                            notif.data.contains("true") ? true : false;
                        return Switch(
                          value: notification,
                          onChanged: (newNotifState) {
                            _accountRepo
                                .setNotificationState(newNotifState.toString());
                            setState(() {});
                          },
                        );
                      } else {
                        return Switch(
                          value: true,
                          onChanged: (newNotifState) {
                            _accountRepo
                                .setNotificationState(newNotifState.toString());
                            setState(() {});
                          },
                        );
                      }
                    })),
            settingsRow(context,
                iconData: Icons.language,
                title: appLocalization.getTraslateValue("changeLanguage"),
                child: DropdownButton(
                    hint: Text(
                      (_uxService.locale as Locale).language().name,
                      style: TextStyle(color: ExtraTheme.of(context).text),
                    ),
                    onChanged: (Language language) {
                      _changeLanguage(language);
                    },
                    items: Language.languageList()
                        .map<DropdownMenuItem<Language>>(
                            (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(lang.flag),
                                      Text(lang.name),
                                    ],
                                  ),
                                ))
                        .toList())),
          ]),
        ));
  }

  Widget settingsRow(BuildContext context,
      {Widget child, IconData iconData, String title, Function onClick}) {
    return GestureDetector(
      onTap: () {
        onClick?.call();
      },
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                SizedBox(width: 8),
                Icon(
                  iconData,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).primaryTextTheme.button,
                ),
              ],
            ),
            child
          ],
        ),
      ),
    );
  }
}
