import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';

import 'package:deliver_flutter/services/routing_service.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/settings_row.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/floating_modal_bottom_sheet.dart';
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
import 'package:logger/logger.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _logger = GetIt.I.get<Logger>();
  final _uxService = GetIt.I.get<UxService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  bool isDeveloperMode = false || kDebugMode;
  bool _uploadNewAvatar = false;
  String _newAvatarPath;
  int developerModeCounterCountDown = 10;

  final _routingServices = GetIt.I.get<RoutingService>();

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
      await _avatarRepo.uploadAvatar(File(path), _authRepo.currentUserUid);
      setState(() {
        _uploadNewAvatar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxOuterBackground,
            elevation: 0,
            title: Align(
              alignment: Alignment.center,
              child: Text(
                appLocalization.getTraslateValue("settings"),
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            leading: _routingService.backButtonLeading(),
            titleSpacing: -30,
          ),
        ),
        body: FluidContainerWidget(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(shrinkWrap: true, children: [
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            var lastAvatar = await _avatarRepo.getLastAvatar(
                                _authRepo.currentUserUid, false);
                            if (lastAvatar.createdOn != null) {
                              _routingServices.openShowAllAvatars(
                                  uid: _authRepo.currentUserUid,
                                  hasPermissionToDeleteAvatar: true,
                                  heroTag: "avatar");
                            }
                          },
                          child: _newAvatarPath != null
                              ? CircleAvatar(
                                  radius: 30,
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
                                  30,
                                  showAsStreamOfAvatar: true,
                                )),
                      SizedBox(width: 15),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder<Account>(
                              future: _accountRepo.getAccount(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Account> snapshot) {
                                var account = snapshot.data ?? Account();
                                return Expanded(
                                  child: Text(
                                    "${account.firstName ?? ""} ${account.lastName ?? ""}"
                                        .trim(),
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color:
                                            ExtraTheme.of(context).textField),
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ExtraTheme.of(context).menuIconButton,
                              ),
                              child: IconButton(
                                  iconSize: 25,
                                  onPressed: () => attachFile(),
                                  icon: Icon(
                                    Icons.add_a_photo,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ExtraTheme.of(context).menuIconButton,
                              ),
                              child: IconButton(
                                  iconSize: 25,
                                  onPressed: () async {
                                    var account =
                                        await _accountRepo.getAccount();
                                    showQrCode(
                                        context,
                                        buildShareUserUrl(
                                            account.countryCode,
                                            account.nationalNumber,
                                            account.firstName,
                                            account.lastName));
                                  },
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              SettingsRow(
                  iconData: Icons.person,
                  title: appLocalization.getTraslateValue("account_info"),
                  onClick: () => _routingService.openAccountSettings(),
                  child: Row(
                    children: <Widget>[
                      FutureBuilder<Account>(
                        future: _accountRepo.getAccount(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Account> snapshot) {
                          if (snapshot.data != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data.userName ?? "",
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).textField,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  buildPhoneNumber(snapshot.data.countryCode,
                                      snapshot.data.nationalNumber),
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).textField,
                                      fontSize: 12),
                                )
                              ],
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
              SettingsRow(
                  iconData: Icons.bookmark,
                  title: appLocalization.getTraslateValue("saved_message"),
                  onClick: () => _routingService
                      .openRoom(_authRepo.currentUserUid.asString()),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.navigate_next),
                  )),
              SettingsRow(
                  iconData: Icons.contacts,
                  title: appLocalization.getTraslateValue("contacts"),
                  onClick: () => _routingService.openContacts(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.navigate_next),
                  )),
              SettingsRow(
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
                SettingsRow(
                  iconData: Icons.keyboard,
                  title:
                      appLocalization.getTraslateValue("send_by_shift_enter"),
                  onClick: () => setState(() => _uxService.toggleSendByEnter()),
                  child: Switch(
                    activeColor: ExtraTheme.of(context).activeSwitch,
                    value: !_getSendByEnter(),
                    onChanged: (_) {},
                  ),
                ),
              SettingsRow(
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
              SettingsRow(
                  iconData: Icons.language,
                  title: appLocalization.getTraslateValue("changeLanguage"),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: DropdownButton(
                        underline: SizedBox.shrink(),
                        hint: Text(
                          (_uxService.locale as Locale).language().name,
                          style: TextStyle(
                              color: ExtraTheme.of(context).textField),
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
                SettingsRow(
                    iconData: Icons.bug_report_rounded,
                    title: "Log Level",
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: DropdownButton(
                          underline: SizedBox.shrink(),
                          hint: Text(
                            LogLevelHelper.levelToString(
                                GetIt.I.get<DeliverLogFilter>().level),
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
              SettingsRow(
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
                                    text: snapshot.data ??
                                        "No Hashcode" + " - ")),
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
              Divider(),
              SettingsRow(
                  iconData: Icons.exit_to_app,
                  title: appLocalization.getTraslateValue("Log_out"),
                  onClick: () =>
                      openLogoutAlertDialog(context, appLocalization),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.exit_to_app),
                  )),
            ]),
          ),
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
}
