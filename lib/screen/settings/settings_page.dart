import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/account.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';

import 'package:deliver_flutter/services/routing_service.dart';

import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/dark.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:logger/logger.dart';

import 'package:settings_ui/settings_ui.dart';

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
  int developerModeCounterCountDown = 10;

  final _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    I18N appLocalization = I18N.of(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              // elevation: 0,
              titleSpacing: 8,
              title: Text(
                appLocalization.get("settings"),
                style: Theme.of(context).textTheme.headline2,
              ),
              leading: _routingService.backButtonLeading(),
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: SettingsList(
            lightBackgroundColor: ExtraTheme.of(context).boxBackground,
            darkBackgroundColor: ExtraTheme.of(context).boxBackground,
            sections: [
              SettingsSection(
                tiles: [
                  NormalSettingsTitle(
                      onTap: () => _routingService.openAccountSettings(),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                var lastAvatar =
                                    await _avatarRepo.getLastAvatar(
                                        _authRepo.currentUserUid, false);
                                if (lastAvatar.createdOn != null) {
                                  _routingServices.openShowAllAvatars(
                                      uid: _authRepo.currentUserUid,
                                      hasPermissionToDeleteAvatar: true,
                                      heroTag: "avatar");
                                }
                              },
                              child: CircleAvatarWidget(
                                _authRepo.currentUserUid,
                                35,
                                showAsStreamOfAvatar: true,
                              )),
                          SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<Account>(
                              future: _accountRepo.getAccount(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Account> snapshot) {
                                if (snapshot.data != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${snapshot.data.firstName ?? ""} ${snapshot.data.lastName ?? ""}"
                                            .trim(),
                                        overflow: TextOverflow.fade,
                                        // maxLines: 1,
                                        textDirection: TextDirection.rtl,
                                        // softWrap: false,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: ExtraTheme.of(context)
                                                .textField),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        snapshot.data.userName ?? "",
                                        style: TextStyle(
                                            color:
                                                ExtraTheme.of(context).username,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        buildPhoneNumber(
                                            snapshot.data.countryCode,
                                            snapshot.data.nationalNumber),
                                        style: TextStyle(
                                            color: ExtraTheme.of(context)
                                                .textField,
                                            fontSize: 12),
                                      )
                                    ],
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.navigate_next),
                          )
                        ],
                      ))
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: appLocalization.get("qr_share"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    leading: Icon(Icons.qr_code),
                    onPressed: (BuildContext context) async {
                      var account = await _accountRepo.getAccount();
                      showQrCode(
                          context,
                          buildShareUserUrl(
                              account.countryCode,
                              account.nationalNumber,
                              account.firstName,
                              account.lastName));
                    },
                  ),
                  SettingsTile(
                    title: appLocalization.get("saved_message"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    leading: Icon(Icons.bookmark),
                    onPressed: (BuildContext context) {
                      _routingService
                          .openRoom(_authRepo.currentUserUid.asString());
                    },
                  ),
                  SettingsTile(
                    title: appLocalization.get("contacts"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    leading: Icon(Icons.contacts),
                    onPressed: (BuildContext context) {
                      _routingService.openContacts();
                    },
                  )
                ],
              ),
              SettingsSection(
                title: appLocalization.get("user_experience"),
                titleTextStyle:
                    TextStyle(color: ExtraTheme.of(context).textField),
                tiles: [
                  SettingsTile.switchTile(
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    title: appLocalization.get("notification"),
                    leading: Icon(Icons.notifications_active),
                    switchValue: _uxService.isAllNotificationDisabled,
                    onToggle: (value) => setState(
                        () => _uxService.toggleIsAllNotificationDisabled()),
                  ),
                  SettingsTile(
                    title: appLocalization.get("language"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    subtitle: _uxService.locale.language().name,
                    leading: Icon(Icons.language),
                    onPressed: (BuildContext context) {
                      _routingService.openLanguageSettings();
                    },
                  ),
                  SettingsTile.switchTile(
                    title: appLocalization.get("dark_mode"),
                    leading: Icon(Icons.brightness_2),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    switchValue: _uxService.theme == DarkTheme,
                    onToggle: (value) {
                      setState(() {
                        _uxService.toggleTheme();
                      });
                    },
                  ),
                  SettingsTile(
                    title: appLocalization.get("devices"),
                    leading: Icon(Icons.devices),
                    titleTextStyle:
                    TextStyle(color: ExtraTheme.of(context).textField),
                    onPressed: (c){
                      _routingService.openDevicesPage();
                    },
                  ),
                  if (isDesktop())
                    SettingsTile.switchTile(
                      title: appLocalization
                          .get("send_by_shift_enter"),
                      titleTextStyle:
                          TextStyle(color: ExtraTheme.of(context).textField),
                      leading: Icon(Icons.keyboard),
                      switchValue: !_uxService.sendByEnter,
                      onToggle: (bool value) {
                        setState(() => _uxService.toggleSendByEnter());
                      },
                    )
                ],
              ),
              if (isDeveloperMode)
                SettingsSection(
                  title: 'Developer Mode',
                  tiles: [
                    SettingsTile(
                      title: 'Log Level',
                      titleTextStyle:
                          TextStyle(color: ExtraTheme.of(context).textField),
                      subtitle: LogLevelHelper.levelToString(
                          GetIt.I.get<DeliverLogFilter>().level),
                      leading: Icon(Icons.bug_report_rounded),
                      onPressed: (BuildContext context) {
                        _routingService.openLogSettings();
                      },
                    )
                  ],
                ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                      title: appLocalization.get("version"),
                      titleTextStyle:
                          TextStyle(color: ExtraTheme.of(context).textField),
                      trailing: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return isDeveloperMode
                                ? FutureBuilder<String>(
                                    future: SmsAutoFill().getAppSignature,
                                    builder: (c, sms) {
                                      return Text(
                                        sms.data ?? snapshot.data.version ?? "",
                                        style: TextStyle(
                                            color: ExtraTheme.of(context)
                                                .textField,
                                            fontSize: 16),
                                      );
                                    })
                                : Text(
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
                      onPressed: (_) async {
                        _logger.d(developerModeCounterCountDown);
                        developerModeCounterCountDown--;
                        if (developerModeCounterCountDown < 1) {
                          setState(() {
                            isDeveloperMode = true;
                          });
                        }
                      }),
                  SettingsTile(
                    title: appLocalization.get("logout"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    leading: Icon(Icons.exit_to_app),
                    onPressed: (BuildContext context) =>
                        openLogoutAlertDialog(context, appLocalization),
                    trailing: SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void openLogoutAlertDialog(
      BuildContext context, I18N appLocalization) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            // backgroundColor: Colors.white,
            content: Container(
              child: Text(appLocalization.get("sure_exit_app"),
                  style: Theme.of(context).dialogTheme.titleTextStyle),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLocalization.get("cancel"))),
              SizedBox(
                width: 15,
              ),
              TextButton(
                  onPressed: () => _routingService.logout(context),
                  child: Text(
                    appLocalization.get("logout"),
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ))
            ],
          );
        });
  }
}

class NormalSettingsTitle extends SettingsTile {
  final Widget child;
  final VoidCallback onTap;

  NormalSettingsTitle({this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
