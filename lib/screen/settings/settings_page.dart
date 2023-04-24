import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/lock/lock.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/release_badge.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _accountRepo = GetIt.I.get<AccountRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _backgroundService = GetIt.I.get<BackgroundService>();
  static final _analyticsService = GetIt.I.get<AnalyticsService>();
  StreamSubscription<dynamic>? subscription;

  final account = BehaviorSubject<Account?>.seeded(null);

  @override
  void initState() {
    _accountRepo
      ..getUserProfileFromServer()
      ..fetchCurrentUserId();
    subscription = MergeStream([
      _accountRepo.getAccountAsStream().map(account.add),
      settings.showDeveloperPage.stream.map((event) => setState(() {}))
    ]).listen((value) {});
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    account.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("settings")),
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
                          final lastAvatar = await _avatarRepo
                              .getLastAvatar(_authRepo.currentUserUid);
                          if (lastAvatar?.createdOn != null &&
                              lastAvatar!.createdOn > 0) {
                            _routingService.openShowAllAvatars(
                              uid: _authRepo.currentUserUid,
                              hasPermissionToDeleteAvatar: true,
                              heroTag: "avatar",
                            );
                          }
                        },
                        child: CircleAvatarWidget(
                          _authRepo.currentUserUid,
                          35,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StreamBuilder<Account?>(
                          stream: account.stream,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    buildName(
                                      snapshot.data!.firstname,
                                      snapshot.data!.lastname,
                                    ),
                                    overflow: TextOverflow.fade,
                                    // maxLines: 1,
                                    textDirection: TextDirection.rtl,
                                    // softWrap: false,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    snapshot.data!.username ?? "",
                                    style: theme.primaryTextTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    buildPhoneNumber(
                                      snapshot.data!.countryCode!,
                                      snapshot.data!.nationalNumber!,
                                    ),
                                    textDirection: TextDirection.ltr,
                                    style: theme.textTheme.titleMedium,
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
                        padding: const EdgeInsetsDirectional.only(start: 4.0),
                        child: const Icon(Icons.navigate_next),
                      )
                    ],
                  ),
                )
              ],
            ),
            StreamBuilder<bool>(
              stream: _authRepo.isLocalLockEnabledStream,
              builder: (context, snapshot) {
                return Section(
                  title: _i18n.get("other"),
                  children: [
                    SettingsTile(
                      title: _i18n.get("qr_share"),
                      leading: const Icon(CupertinoIcons.qrcode),
                      onPressed: (context) async {
                        await _analyticsService.sendLogEvent(
                          "QRShare",
                        );
                        final account = await _accountRepo.getAccount();
                        // Forced
                        // ignore: use_build_context_synchronously
                        showQrCode(
                          context,
                          buildShareUserUrl(
                            account!.countryCode!,
                            account.nationalNumber!,
                            account.firstname!,
                            account.lastname!,
                          ),
                        );
                      },
                    ),
                    if (snapshot.hasData && snapshot.data!)
                      SettingsTile(
                        title: _i18n.get("lock_app"),
                        leading: const Icon(CupertinoIcons.lock),
                        onPressed: (context) {
                          Navigator.pushReplacement(
                            settings.appContext,
                            MaterialPageRoute(
                              builder: (c) {
                                return const LockPage();
                              },
                            ),
                          );
                        },
                      ),
                    SettingsTile(
                      title: _i18n.get("saved_message"),
                      leading: const Icon(CupertinoIcons.bookmark),
                      onPressed: (context) async {
                        _routingService
                            .openRoom(_authRepo.currentUserUid.asString());
                      },
                    ),
                    SettingsTile(
                      title: _i18n.get("contacts"),
                      leading: const Icon(CupertinoIcons.person_2),
                      onPressed: (context) {
                        _routingService.openContacts();
                      },
                    ),
                  ],
                );
              },
            ),
            Section(
              title: _i18n.get("user_experience"),
              children: [
                SettingsTile.switchTile(
                  title: _i18n.get("notification"),
                  leading: const Icon(CupertinoIcons.bell),
                  switchValue: !settings.isAllNotificationDisabled.value,
                  onToggle: (value) => setState(
                    () => settings.isAllNotificationDisabled.toggleValue(),
                  ),
                ),
                SettingsTile.switchTile(
                  title: _i18n.get("events"),
                  leading: const Icon(CupertinoIcons.calendar),
                  switchValue: settings.showEvents.value,
                  onToggle: (value) => setState(
                    () => settings.showEvents.toggleValue(),
                  ),
                ),
                if (isAndroidNative)
                  SettingsTile.switchTile(
                    title: _i18n.get("notification_advanced_mode"),
                    leading: const Icon(CupertinoIcons.bell_circle_fill),
                    switchValue:
                        !settings.isNotificationAdvanceModeDisabled.value,
                    onToggle: (value) => value
                        ? _showNotificationAdvanceModeDialog()
                        : setState(() {
                            settings.isNotificationAdvanceModeDisabled
                                .toggleValue();
                          }),
                  ),
                SettingsTile(
                  title: _i18n.get("language"),
                  subtitle: _i18n.language.languageName,
                  leading: const Icon(CupertinoIcons.globe),
                  onPressed: (context) {
                    _routingService.openLanguageSettings();
                  },
                ),
                SettingsTile(
                  title: _i18n.get("security"),
                  leading: const Icon(CupertinoIcons.shield_lefthalf_fill),
                  onPressed: (context) =>
                      _routingService.openSecuritySettings(),
                ),
                SettingsTile(
                  title: _i18n.get("devices"),
                  leading: const Icon(CupertinoIcons.device_desktop),
                  onPressed: (c) {
                    _routingService.openDevices();
                  },
                ),
                if (isDesktopDevice)
                  SettingsTile.switchTile(
                    title: _i18n.get("send_by_shift_enter"),
                    leading: const Icon(CupertinoIcons.keyboard),
                    switchValue: !settings.sendByEnter.value,
                    onToggle: (value) {
                      setState(() => settings.sendByEnter.toggleValue());
                    },
                  ),
                if (_featureFlags.isVoiceCallAvailable())
                  SettingsTile(
                    title: _i18n.get("call"),
                    leading: const Icon(CupertinoIcons.phone),
                    releaseState: ReleaseState.NEW,
                    onPressed: (context) => _routingService.openCallSetting(),
                  ),
                SettingsTile(
                  title: _i18n["power_saver"],
                  leading: const Icon(CupertinoIcons.battery_25),
                  releaseState: ReleaseState.NEW,
                  onPressed: (context) {
                    _routingService.openPowerSaverSettings();
                  },
                ),
              ],
            ),
            Section(
              title: _i18n.get("theme"),
              children: [
                SettingsTile.switchTile(
                  title: _i18n.get("dark_mode"),
                  leading: const Icon(CupertinoIcons.moon),
                  switchValue: settings.themeIsDark.value,
                  onToggle: (value) {
                    setState(() {
                      settings.isAutoNightModeEnable.set(false);
                      settings.themeIsDark.toggleValue();
                    });
                  },
                ),
                SettingsTile(
                  title: _i18n.get("advanced_settings"),
                  leading: const Icon(CupertinoIcons.paintbrush),
                  releaseState: ReleaseState.NEW,
                  onPressed: (context) {
                    _routingService.openThemeSettings();
                  },
                ),
              ],
            ),
            Section(
              title: _i18n.get("network"),
              children: [
                SettingsTile(
                  title: _i18n.get("automatic_download"),
                  leading: const Icon(CupertinoIcons.cloud_download),
                  onPressed: (context) => _routingService.openAutoDownload(),
                ),
                SettingsTile(
                  title: _i18n.get("connection_settings"),
                  leading: const Icon(CupertinoIcons.settings),
                  onPressed: (context) =>
                      _routingService.openConnectionSettingPage(),
                ),
              ],
            ),
            if (settings.showDeveloperPage.value)
              Section(
                title: 'Developer Mode',
                children: [
                  SettingsTile(
                    title: 'Developer Page',
                    subtitle: "Log Level: ${settings.logLevel.value.name}",
                    leading: const Icon(Icons.bug_report_rounded),
                    onPressed: (context) => _routingService.openDeveloperPage(),
                  )
                ],
              ),
            Section(
              children: [
                SettingsTile(
                  title: _i18n.get("about_software"),
                  subtitle: "${_i18n.get("version")} $VERSION",
                  leading: const Icon(Icons.info_outline_rounded),
                  onPressed: (context) =>
                      _routingService.openAboutSoftwarePage(),
                ),
                SettingsTile(
                  title: _i18n.get("logout"),
                  leading: const Icon(CupertinoIcons.square_arrow_left),
                  onPressed: (context) => openLogoutAlertDialog(context, _i18n),
                  trailing: const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationAdvanceModeDialog() {
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
          content: Text(
            _i18n.get("notification_advance_mode_description"),
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(c);
                if (await _backgroundService.enableListenOnSmsAnCall()) {
                  setState(
                    () => settings.isNotificationAdvanceModeDisabled
                        .toggleValue(),
                  );
                }
              },
              child: Text(_i18n.get("continue")),
            ),
          ],
        );
      },
    );
  }

  void openLogoutAlertDialog(BuildContext context, I18N i18n) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
          // backgroundColor: Colors.white,
          content: Text(
            i18n.get("sure_exit_app"),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(i18n.get("cancel")),
            ),
            const SizedBox(
              width: 15,
            ),
            TextButton(
              onPressed: () => _routingService.logout(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(i18n.get("logout")),
            ),
          ],
        );
      },
    );
  }
}

class NormalSettingsTitle extends SettingsTile {
  final Widget child;

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
