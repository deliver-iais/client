import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';

import 'package:deliver_flutter/services/routing_service.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profile_avatar_card.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _logger = Logger();
  final _uxService = GetIt.I.get<UxService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  bool isDeveloperMode = false || kDebugMode;
  bool _uploadNewAvatar = false;
  String _newAvatarPath;
  int developerModeCounterCountDown = 10;

  bool _getTheme() {
    if (_uxService.theme == DarkTheme) {
      return true;
    } else {
      return false;
    }
  }

  bool _getSendByEnter() {
    if (_uxService.sendByEnter == SEND_BY_ENTER) {
      return true;
    } else {
      return false;
    }
  }

  attachFile() async {
    String path;
    if (isDesktop()) {
      final typeGroup = XTypeGroup(
          label: 'images', extensions: ['png', 'jpg', 'jpeg', 'gif']);
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
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            leading: _routingService.backButtonLeading()),
        body: FluidContainerWidget(
          child: ListView(children: [
            ProfileAvatarCard(
              uploadNewAvatar: _uploadNewAvatar,
              newAvatarPath: _newAvatarPath,
              uid: _accountRepo.currentUserUid,
            ),
            SizedBox(height: 10),
            settingsRow(context,
                iconData: Icons.add_a_photo,
                title: appLocalization.getTraslateValue("set_avatar"),
                onClick: () => attachFile(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(right: 14.0),
                  child: Icon(Icons.add_a_photo),
                )),
            settingsRow(context,
                iconData: Icons.bookmark,
                title: appLocalization.getTraslateValue("saved_message"),
                onClick: () => _routingService
                    .openRoom(_accountRepo.currentUserUid.asString()),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.navigate_next),
                )),
            settingsRow(context,
                iconData: Icons.person,
                title: appLocalization.getTraslateValue("username"),
                onClick: () => _routingService.openAccountSettings(),
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
                                color: ExtraTheme.of(context).textField,
                                fontSize: 13),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.navigate_next),
                    )
                  ],
                )),
            settingsRow(
              context,
              iconData: Icons.phone,
              title: appLocalization.getTraslateValue("phone"),
              onClick: () => _routingService.openAccountSettings(),
              child: Row(
                children: <Widget>[
                  FutureBuilder<Account>(
                    future: _accountRepo.getAccount(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Account> snapshot) {
                      if (snapshot.data != null) {
                        return Text(
                          buildPhoneNumber(snapshot.data.countryCode,
                              snapshot.data.nationalNumber),
                          style: TextStyle(
                              color: ExtraTheme.of(context).textField,
                              fontSize: 13),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.navigate_next),
                  ),
                ],
              ),
            ),
            settingsRow(
              context,
              iconData: Icons.brightness_2,
              title: appLocalization.getTraslateValue("dark_mode"),
              onClick: () => setState(() => _uxService.toggleTheme()),
              child: Switch(
                activeColor: ExtraTheme.of(context).activeSwitch,
                value: _getTheme(),
                onChanged: (_) {},
              ),
            ),
            if (isDesktop())
              settingsRow(
                context,
                iconData: Icons.keyboard,
                title: appLocalization.getTraslateValue("send_by_shift_enter"),
                onClick: () => setState(() => _uxService.toggleSendByEnter()),
                child: Switch(
                  activeColor: ExtraTheme.of(context).activeSwitch,
                  value: !_getSendByEnter(),
                  onChanged: (_) {},
                ),
              ),
            settingsRow(context,
                iconData: Icons.notifications_active,
                title: appLocalization.getTraslateValue("notification"),
                child: FutureBuilder<String>(
                    future: _accountRepo.notification,
                    builder: (c, notificationStatus) {
                      return Switch(
                        value: (notificationStatus.data ?? "true")
                                .contains("false")
                            ? false
                            : true,
                        activeColor: ExtraTheme.of(context).activeSwitch,
                        onChanged: (newNotificationState) {
                          _accountRepo.setNotificationState(
                              newNotificationState.toString());
                          setState(() {});
                        },
                      );
                    })),
            settingsRow(context,
                iconData: Icons.language,
                title: appLocalization.getTraslateValue("changeLanguage"),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton(
                      underline: SizedBox.shrink(),
                      hint: Text(
                        (_uxService.locale as Locale).language().name,
                        style:
                            TextStyle(color: ExtraTheme.of(context).textField),
                      ),
                      onChanged: (Language language) {
                        _uxService.changeLanguage(language);
                      },
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                              (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(lang.flag,
                                            style: TextStyle(
                                                color: ExtraTheme.of(context)
                                                    .textField)),
                                        Text(lang.name,
                                            style: TextStyle(
                                                color: ExtraTheme.of(context)
                                                    .textField)),
                                      ],
                                    ),
                                  ))
                          .toList()),
                )),
            if (isDeveloperMode)
              settingsRow(context,
                  iconData: Icons.bug_report_rounded,
                  title: "Log Level",
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: DropdownButton(
                        underline: SizedBox.shrink(),
                        hint: Text(
                          LogLevelHelper.levelToString(Logger.level),
                          style: TextStyle(
                              color: ExtraTheme.of(context).textField),
                        ),
                        onChanged: (String level) {
                          setState(() {
                            _uxService.changeLogLevel(level);
                          });
                        },
                        items: LogLevelHelper.levels()
                            .map<DropdownMenuItem<String>>((level) =>
                                DropdownMenuItem(
                                    value: level,
                                    child: Text(level,
                                        style: TextStyle(
                                            color: ExtraTheme.of(context)
                                                .textField))))
                            .toList()),
                  )),
            Divider(),
            settingsRow(
              context,
              iconData: Icons.copyright_outlined,
              title: appLocalization.getTraslateValue("version"),
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: <Widget>[
                    if (isDeveloperMode)
                      FutureBuilder(
                        future: SmsAutoFill().getAppSignature,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return GestureDetector(
                              onTap: () => Clipboard.setData(ClipboardData(
                                  text:
                                      snapshot.data ?? "No Hashcode" + " - ")),
                              child: Text(
                                snapshot.data ?? "No Hashcode" + " - ",
                                style: TextStyle(
                                    color: ExtraTheme.of(context).textField,
                                    fontSize: 16),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () => Clipboard.setData(ClipboardData(
                                  text: snapshot.data ?? "No Hashcode - ")),
                              child: Text(
                                "No Hashcode - ",
                                style: TextStyle(
                                    color: ExtraTheme.of(context).textField,
                                    fontSize: 16),
                              ),
                            );
                          }
                        },
                      ),
                    GestureDetector(
                      onTap: () async {
                        _logger.d(developerModeCounterCountDown);
                        developerModeCounterCountDown--;
                        if (developerModeCounterCountDown < 1) {
                          setState(() {
                            isDeveloperMode = true;
                          });
                        }
                      },
                      child: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Text(
                              snapshot.data.version ?? "",
                              style: TextStyle(
                                  color: ExtraTheme.of(context).textField,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            settingsRow(
              context,
              iconData: Icons.info_outlined,
              title: appLocalization.getTraslateValue("about"),
              onClick: () async {
                showAboutDialog(
                    context: context,
                    applicationIcon: Image(
                      width: 50,
                      height: 50,
                      image: AssetImage(
                          'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png'),
                    ),
                    applicationName: APPLICATION_NAME,
                    applicationVersion:
                        (await PackageInfo.fromPlatform()).version,
                    children: [
                      TextButton(
                          onPressed: () => launch(
                              "https://doc.deliver-co.ir/blogs/updates/"),
                          child: Text("What's new"))
                    ]);
              },
              child: Container(),
            ),
            settingsRow(context,
                iconData: Icons.exit_to_app,
                title: appLocalization.getTraslateValue("Log_out"),
                onClick: () => openLogoutAlertDialog(context, appLocalization),
                child: IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () =>
                      openLogoutAlertDialog(context, appLocalization),
                )),
          ]),
        ));
  }

  void openLogoutAlertDialog(
      BuildContext context, AppLocalization appLocalization) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            // backgroundColor: Colors.white,
            content: Container(
              child: Text(appLocalization.getTraslateValue("sure_exit_app"),
                  style: Theme.of(context).dialogTheme.titleTextStyle),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLocalization.getTraslateValue("cancel"))),
              SizedBox(
                width: 15,
              ),
              TextButton(
                  onPressed: () => _routingService.logout(context),
                  child: Text(
                    appLocalization.getTraslateValue("Log_out"),
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ))
            ],
          );
        });
  }

  Widget settingsRow(BuildContext context,
      {Widget child, IconData iconData, String title, Function onClick}) {
    return MouseRegion(
      cursor: onClick == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onClick?.call();
        },
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width: 8),
                  Icon(
                    iconData,
                    color: Colors.blue,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                        color: ExtraTheme.of(context).textField, fontSize: 16),
                  ),
                ],
              ),
              child
            ],
          ),
        ),
      ),
    );
  }
}
