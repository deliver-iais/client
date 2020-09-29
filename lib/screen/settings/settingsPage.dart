import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';

import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/screen/settings/accountSetting.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profile_avatar_card.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:file_chooser/file_chooser.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key key}) : super(key: key);

  final _uxService = GetIt.I.get<UxService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var _notification = false;

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
      print(path);
      Avatar avatar = await _avatarRepo.uploadAvatar(File(path));
      if (avatar != null) {

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            appLocalization.getTraslateValue("settings"),
            style: Theme.of(context).textTheme.headline3,
          ),
          leading: _routingService.canPop()
              ? BackButton(
                  color: ExtraTheme.of(context).infoChat,
                  onPressed: () {
                    _routingService.pop();
                  },
                )
              : null,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: BREAKDOWN_SIZE),
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.all(MAIN_PADDING),
                child: ProfileAvatarCard(
                  userUid: _accountRepo.currentUserUid,
                  buttons: [
                    MaterialButton(
                      color: Theme.of(context).buttonColor,
                      onPressed: () {
                        attachFile();
                      },
                      shape: CircleBorder(),
                      child: Icon(Icons.add_a_photo_rounded),
                      padding: const EdgeInsets.all(20),
                    ),
                    MaterialButton(
                      color: Theme.of(context).buttonColor,
                      onPressed: () {},
                      shape: CircleBorder(),
                      child: Icon(Icons.bookmark),
                      padding: const EdgeInsets.all(20),
                    ),
                    Tooltip(
                      message: appLocalization.getTraslateValue("Log_out"),
                      child: MaterialButton(
                        color: Theme.of(context).errorColor,
                        onPressed: () {
                          deleteDb();
                          _routingService.reset();
                          Navigator.of(context).pushAndRemoveUntil(
                              new MaterialPageRoute(
                                  builder: (context) => IntroPage()),
                              (Route<dynamic> route) => false);
                        },
                        shape: CircleBorder(),
                        child: Icon(Icons.exit_to_app_rounded),
                        padding: const EdgeInsets.all(20),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              settingsRow(context,
                  isStart: true,
                  iconData: Icons.person,
                  title: appLocalization.getTraslateValue("username"),
                  child: Row(
                    children: <Widget>[
                      Text(
                        _accountRepo.currentUsername,
                        style: TextStyle(
                            color: ExtraTheme.of(context).text, fontSize: 13),
                      ),
                      IconButton(
                          icon: Icon(Icons.navigate_next), onPressed: () {
                        ExtendedNavigator.of(context).popAndPush(Routes.accountInfo);

                      }),
                    ],
                  )),
              settingsRow(
                context,
                iconData: Icons.person,
                title: appLocalization.getTraslateValue("phone"),
                child: Row(
                  children: <Widget>[
                    Text(
                      '091222222222',
                      style: TextStyle(
                          color: ExtraTheme.of(context).text, fontSize: 13),
                    ),
                    IconButton(
                        icon: Icon(Icons.navigate_next), onPressed: () {}),
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
                  child: Switch(
                    value: _notification,
                    onChanged: (newNotifState) {
                      _notification = newNotifState;
                    },
                  )),
              settingsRow(context,
                  isEnd: true,
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
          ),
        ));
  }

  Widget settingsRow(BuildContext context,
      {Widget child,
      IconData iconData,
      String title,
      bool isStart = false,
      bool isEnd = false,
      Function onClick}) {
    double extraStartBorder = isStart ? MAIN_BORDER_RADIUS * 2 : 0;
    double extraEndBorder = isEnd ? MAIN_BORDER_RADIUS * 2 : 0;

    return GestureDetector(
      onTap: () {
        onClick?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(MAIN_BORDER_RADIUS + extraStartBorder),
                topRight:
                    Radius.circular(MAIN_BORDER_RADIUS + extraStartBorder),
                bottomLeft:
                    Radius.circular(MAIN_BORDER_RADIUS + extraEndBorder),
                bottomRight:
                    Radius.circular(MAIN_BORDER_RADIUS + extraEndBorder)),
            // border: Border.all(color: ExtraTheme.of(context).borderOfProfilePage),
            color: Theme.of(context).cardColor),
        height: 60,
        padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
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

  Future<void> deleteDb() async {
    Database db = Database();
    await db.deleteAllData();
  }
}
