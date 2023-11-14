import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/lock/lock.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/core_services.dart';
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
import "package:deliver/web_classes/html.dart"
    if (dart.library.html) 'dart:html' as html;
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
  static final _coreService = GetIt.I.get<CoreServices>();
  StreamSubscription<dynamic>? subscription;

  final _account = BehaviorSubject<Account?>.seeded(null);

  @override
  void initState() {
    _accountRepo.getUserProfileFromServer();
    subscription = MergeStream([
      _accountRepo.getAccountAsStream().map(_account.add),
      settings.showDeveloperPage.stream.map((event) => setState(() {}))
    ]).listen((value) {});
    super.initState();
  }

  @override
  void dispose() {
    subscription?.cancel();
    _account.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FluidContainerWidget(
        child: ListView(
          children: [
            const SizedBox(height: p24),
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
                          stream: _account.stream,
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
                                  if (snapshot.data!.countryCode != null &&
                                      snapshot.data!.nationalNumber != null)
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
                        final account = _accountRepo.getAccount();
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
                        _routingService.openRoom(
                          _authRepo.currentUserUid.asString(),
                          popAllBeforePush: true,
                        );
                      },
                    ),
                    SettingsTile(
                      title: _i18n.get("contacts"),
                      leading: const Icon(CupertinoIcons.person_2),
                      onPressed: (context) {
                        _routingService.openContacts(popAllBeforePush: true);
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
                  leading: const Icon(CupertinoIcons.volume_off),
                  switchValue: !settings.isAllNotificationDisabled.value,
                  onToggle: ({required newValue}) => setState(
                    () => settings.isAllNotificationDisabled.toggleValue(),
                  ),
                ),
                SettingsTile.switchTile(
                  title: _i18n.get("events"),
                  leading: const Icon(CupertinoIcons.calendar),
                  switchValue: settings.showEvents.value,
                  onToggle: ({required newValue}) => setState(
                    () => settings.showEvents.toggleValue(),
                  ),
                ),
                if (isAndroidNative)
                  SettingsTile.switchTile(
                    title: _i18n.get("notification_advanced_mode"),
                    leading: const Icon(CupertinoIcons.volume_down),
                    switchValue:
                        !settings.isNotificationAdvanceModeDisabled.value,
                    onToggle: ({required newValue}) => newValue
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
                    _routingService.openLanguageSettings(
                      popAllBeforePush: true,
                    );
                  },
                ),
                SettingsTile(
                  title: _i18n.get("security"),
                  leading: const Icon(CupertinoIcons.shield_lefthalf_fill),
                  onPressed: (context) => _routingService.openSecuritySettings(
                    popAllBeforePush: true,
                  ),
                ),
                SettingsTile(
                  title: _i18n.get("devices"),
                  leading: const Icon(CupertinoIcons.device_desktop),
                  onPressed: (c) {
                    _routingService.openDevices(popAllBeforePush: true);
                  },
                ),
                if (isDesktopDevice)
                  SettingsTile.switchTile(
                    title: _i18n.get("send_by_shift_enter"),
                    leading: const Icon(CupertinoIcons.keyboard),
                    switchValue: !settings.sendByEnter.value,
                    onToggle: ({required newValue}) {
                      setState(() => settings.sendByEnter.toggleValue());
                    },
                  ),
                if (_featureFlags.isVoiceCallAvailable())
                  SettingsTile(
                    title: _i18n.get("call"),
                    leading: const Icon(CupertinoIcons.phone),
                    releaseState: ReleaseState.NEW,
                    onPressed: (context) =>
                        _routingService.openCallSetting(popAllBeforePush: true),
                  ),
                SettingsTile(
                  title: _i18n["power_saver"],
                  leading: const Icon(CupertinoIcons.battery_25),
                  releaseState: ReleaseState.NEW,
                  onPressed: (context) {
                    _routingService.openPowerSaverSettings(
                      popAllBeforePush: true,
                    );
                  },
                ),
              ],
            ),
            Section(
              title: _i18n.get("local_network"),
              children: [
                SettingsTile.switchTile(
                  title: _i18n.get("local_network"),
                  leading:
                      const Icon(CupertinoIcons.antenna_radiowaves_left_right),
                  switchValue: settings.localNetworkMessenger.value,
                  onToggle: ({required newValue}) {
                    setState(
                      () => settings.localNetworkMessenger.toggleValue(),
                    );
                    _coreService.initStreamConnection();
                  },
                ),
                if (settings.localNetworkMessenger.value)
                  SettingsTile.switchTile(
                    title: _i18n.get("use_default_udp_address"),
                    leading: const Icon(
                      CupertinoIcons.arrow_branch,
                    ),
                    switchValue: settings.useDefaultUdpAddress.value,
                    onToggle: ({required newValue}) {
                      setState(
                        () => settings.useDefaultUdpAddress.toggleValue(),
                      );
                      _coreService.initStreamConnection();
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
                  onToggle: ({required newValue}) {
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
                    _routingService.openThemeSettings(popAllBeforePush: true);
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
                  onPressed: (context) => _routingService
                      .openConnectionSettingPage(popAllBeforePush: true),
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
                    onPressed: (context) => _routingService.openDeveloperPage(
                      popAllBeforePush: true,
                    ),
                  )
                ],
              ),
            Section(
              children: [
                SettingsTile(
                  title: _i18n.get("about_software"),
                  subtitle: "${_i18n.get("version")} $APP_VERSION",
                  leading: const Icon(Icons.info_outline_rounded),
                  onPressed: (context) => _routingService.openAboutSoftwarePage(
                    popAllBeforePush: true,
                  ),
                ),
                SettingsTile.switchTile(
                  title: _i18n.get("automatic_update"),
                  leading: const Icon(Icons.update_rounded),
                  switchValue: settings.autoUpdateIsEnable.value,
                  onToggle: ({required newValue}) {
                    setState(() {
                      settings.autoUpdateIsEnable.toggleValue();
                    });
                  },
                ),
                SettingsTile(
                  title: _i18n.get("logout"),
                  leading: const Icon(CupertinoIcons.square_arrow_left),
                  onPressed: (context) => openLogoutAlertDialog(context, _i18n),
                  trailing: const SizedBox.shrink(),
                ),
                if (isWeb)
                  SettingsTile(
                    title: "Delete Web Storage",
                    leading: const Icon(CupertinoIcons.delete),
                    onPressed: (context) => deleteDBNativeInWeb(),
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

  Future<void> deleteDBNativeInWeb() async {
    await GetIt.I.get<DBManager>().deleteDBNativeInWeb();

    // Ignore window dynamic type for web
    // ignore: avoid_dynamic_calls
    html.window.location.reload();
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
