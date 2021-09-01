import 'package:we/localization/i18n.dart';
import 'package:we/models/account.dart';

import 'package:we/repository/accountRepo.dart';
import 'package:we/repository/authRepo.dart';
import 'package:we/repository/avatarRepo.dart';

import 'package:we/services/routing_service.dart';

import 'package:we/services/ux_service.dart';
import 'package:we/shared/constants.dart';
import 'package:we/shared/methods/platform.dart';
import 'package:we/shared/widgets/circle_avatar.dart';
import 'package:we/shared/floating_modal_bottom_sheet.dart';
import 'package:we/shared/widgets/fluid_container.dart';
import 'package:we/shared/language.dart';
import 'package:we/shared/methods/phone.dart';
import 'package:we/shared/methods/url.dart';
import 'package:we/theme/dark.dart';
import 'package:we/theme/extra_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:we/shared/extensions/uid_extension.dart';
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

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              titleSpacing: 8,
              title: Text(i18n.get("settings")),
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
                                  _routingService.openShowAllAvatars(
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        snapshot.data.userName ?? "",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        buildPhoneNumber(
                                            snapshot.data.countryCode,
                                            snapshot.data.nationalNumber),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
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
                    title: i18n.get("qr_share"),
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
                    title: i18n.get("saved_message"),
                    leading: Icon(Icons.bookmark),
                    onPressed: (BuildContext context) {
                      _routingService
                          .openRoom(_authRepo.currentUserUid.asString());
                    },
                  ),
                  SettingsTile(
                    title: i18n.get("contacts"),
                    leading: Icon(Icons.contacts),
                    onPressed: (BuildContext context) {
                      _routingService.openContacts();
                    },
                  )
                ],
              ),
              SettingsSection(
                title: i18n.get("user_experience"),
                tiles: [
                  SettingsTile.switchTile(
                    title: i18n.get("notification"),
                    leading: Icon(Icons.notifications_active),
                    switchValue: !_uxService.isAllNotificationDisabled,
                    onToggle: (value) => setState(
                        () => _uxService.toggleIsAllNotificationDisabled()),
                  ),
                  SettingsTile(
                    title: i18n.get("language"),
                    subtitle: I18N.of(context).locale.language().name,
                    leading: Icon(Icons.language),
                    onPressed: (BuildContext context) {
                      _routingService.openLanguageSettings();
                    },
                  ),
                  SettingsTile.switchTile(
                    title: i18n.get("dark_mode"),
                    leading: Icon(Icons.brightness_2),
                    switchValue: _uxService.theme == DarkTheme,
                    onToggle: (value) {
                      setState(() {
                        _uxService.toggleTheme();
                      });
                    },
                  ),
                  SettingsTile(
                    title: i18n.get("devices"),
                    leading: Icon(Icons.devices),
                    onPressed: (c) {
                      _routingService.openDevicesPage();
                    },
                  ),
                  if (isDesktop())
                    SettingsTile.switchTile(
                      title: i18n.get("send_by_shift_enter"),
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
                      title: i18n.get("version"),
                      trailing: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return isDeveloperMode
                                ? FutureBuilder<String>(
                                    future: SmsAutoFill().getAppSignature,
                                    builder: (c, sms) {
                                      return Text(
                                        sms.data ?? snapshot.data.version ?? VERSION,
                                      );
                                    })
                                : Text(
                                    snapshot.data.version ?? VERSION,
                                  );
                          } else {
                            return Text(
                              VERSION,
                            );
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
                    title: i18n.get("logout"),
                    leading: Icon(Icons.exit_to_app),
                    onPressed: (BuildContext context) =>
                        openLogoutAlertDialog(context, i18n),
                    trailing: SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void openLogoutAlertDialog(BuildContext context, I18N i18n) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            // backgroundColor: Colors.white,
            content: Container(child: Text(i18n.get("sure_exit_app"))),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(i18n.get("cancel"))),
              SizedBox(
                width: 15,
              ),
              TextButton(
                onPressed: () => _routingService.logout(context),
                child: Text(i18n.get("logout")),
                style: TextButton.styleFrom(primary: Colors.red),
              ),
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
