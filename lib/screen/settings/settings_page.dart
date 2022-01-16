import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/account.dart';

import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';

import 'package:deliver/services/routing_service.dart';

import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/theme/dark.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:logger/logger.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _logger = GetIt.I.get<Logger>();
  final _uxService = GetIt.I.get<UxService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  int developerModeCounterCountDown = kDebugMode ? 1 : 10;
  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            titleSpacing: 8,
            title: Text(
              i18n.get(
                "settings",
              ),
              style: TextStyle(color: ExtraTheme.of(context).textField),
            ),
            leading: _routingService.backButtonLeading(),
          ),
        ),
        body: FluidContainerWidget(
          child: ListView(
            children: [
              Section(
                children: [
                  NormalSettingsTitle(
                      onTap: () => _routingService.openAccountSettings(),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () async {
                                _routingService.openShowAllAvatars(
                                    uid: _authRepo.currentUserUid,
                                    hasPermissionToDeleteAvatar: true,
                                    heroTag: "avatar");
                              },
                              child: CircleAvatarWidget(
                                  _authRepo.currentUserUid, 35)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FutureBuilder<Account?>(
                              future: _accountRepo.getAccount(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Account?> snapshot) {
                                if (snapshot.data != null) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${snapshot.data!.firstName ?? ""} ${snapshot.data!.lastName ?? ""}"
                                            .trim(),
                                        overflow: TextOverflow.fade,
                                        // maxLines: 1,
                                        textDirection: TextDirection.rtl,
                                        // softWrap: false,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        snapshot.data!.userName ?? "",
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        buildPhoneNumber(
                                            snapshot.data!.countryCode!,
                                            snapshot.data!.nationalNumber!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      )
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: const Icon(Icons.navigate_next),
                          )
                        ],
                      ))
                ],
              ),
              Section(
                title: i18n.get("other"),
                children: [
                  SettingsTile(
                    title: i18n.get("qr_share"),
                    leading: const Icon(Icons.qr_code),
                    onPressed: (BuildContext context) async {
                      var account = await _accountRepo.getAccount();
                      showQrCode(
                          context,
                          buildShareUserUrl(
                              account.countryCode!,
                              account.nationalNumber!,
                              account.firstName!,
                              account.lastName!));
                    },
                  ),
                  SettingsTile(
                    title: i18n.get("saved_message"),
                    leading: const Icon(Icons.bookmark),
                    onPressed: (BuildContext context) {
                      _routingService
                          .openRoom(_authRepo.currentUserUid.asString());
                    },
                  ),
                  SettingsTile(
                    title: i18n.get("contacts"),
                    leading: const Icon(Icons.contacts),
                    onPressed: (BuildContext context) {
                      _routingService.openContacts();
                    },
                  )
                ],
              ),
              Section(
                title: i18n.get("user_experience"),
                children: [
                  SettingsTile.switchTile(
                    title: i18n.get("notification"),
                    leading: const Icon(Icons.notifications_active),
                    switchValue: !_uxService.isAllNotificationDisabled,
                    onToggle: (value) => setState(
                        () => _uxService.toggleIsAllNotificationDisabled()),
                  ),
                  SettingsTile(
                    title: i18n.get("language"),
                    subtitle: I18N.of(context)!.locale.language().name,
                    leading: const Icon(Icons.language),
                    onPressed: (BuildContext context) {
                      _routingService.openLanguageSettings();
                    },
                  ),
                  SettingsTile.switchTile(
                    title: i18n.get("dark_mode"),
                    leading: const Icon(Icons.brightness_2),
                    switchValue: _uxService.theme == DarkTheme,
                    onToggle: (value) {
                      setState(() {
                        _uxService.toggleTheme();
                      });
                    },
                  ),
                  SettingsTile(
                    title: i18n.get("security"),
                    leading: const Icon(Icons.security),
                    onPressed: (BuildContext context) =>
                        _routingService.openSecuritySettings(),
                    trailing: const SizedBox.shrink(),
                  ),
                  SettingsTile(
                    title: i18n.get("devices"),
                    leading: const Icon(Icons.devices),
                    onPressed: (c) {
                      _routingService.openDevices();
                    },
                  ),
                  if (isDesktop())
                    SettingsTile.switchTile(
                      title: i18n.get("send_by_shift_enter"),
                      leading: const Icon(Icons.keyboard),
                      switchValue: !_uxService.sendByEnter,
                      onToggle: (bool value) {
                        setState(() => _uxService.toggleSendByEnter());
                      },
                    )
                ],
              ),
              if (UxService.isDeveloperMode)
                Section(
                  title: 'Developer Mode',
                  children: [
                    SettingsTile(
                      title: 'Log Level',
                      subtitle: LogLevelHelper.levelToString(
                          GetIt.I.get<DeliverLogFilter>().level!),
                      leading: const Icon(Icons.bug_report_rounded),
                      onPressed: (BuildContext context) {
                        _routingService.openLogSettings();
                      },
                    )
                  ],
                ),
              Section(
                children: [
                  SettingsTile(
                      title: i18n.get("version"),
                      trailing: UxService.isDeveloperMode
                          ? FutureBuilder<String?>(
                              future: SmsAutoFill().getAppSignature,
                              builder: (c, sms) => Text(sms.data ?? VERSION),
                            )
                          : const Text(VERSION),
                      onPressed: (_) async {
                        _logger.d(developerModeCounterCountDown);
                        developerModeCounterCountDown--;
                        if (developerModeCounterCountDown < 1) {
                          setState(() {
                            UxService.isDeveloperMode = true;
                          });
                        }
                      }),
                  SettingsTile(
                    title: i18n.get("logout"),
                    leading: const Icon(Icons.exit_to_app),
                    onPressed: (BuildContext context) =>
                        openLogoutAlertDialog(context, i18n),
                    trailing: const SizedBox.shrink(),
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
            titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
            // backgroundColor: Colors.white,
            content: Text(i18n.get("sure_exit_app")),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(i18n.get("cancel"))),
              const SizedBox(
                width: 15,
              ),
              TextButton(
                onPressed: () => _routingService.logout(),
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

  @override
  // ignore: overridden_fields
  final VoidCallback? onTap;

  const NormalSettingsTitle({Key? key, this.onTap, required this.child})
      : super(key: key, title: "");

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap?.call(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
