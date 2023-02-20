import 'dart:async';

import 'package:deliver/box/account.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/splash/splash_screen.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/log.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  static final _logger = GetIt.I.get<Logger>();
  static final _uxService = GetIt.I.get<UxService>();
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _accountRepo = GetIt.I.get<AccountRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _backgroundService = GetIt.I.get<BackgroundService>();
  static final _analyticsService = GetIt.I.get<AnalyticsService>();
  StreamSubscription<Account?>? subscription;

  int developerModeCounterCountDown = kDebugMode ? 1 : 10;
  final account = BehaviorSubject<Account?>.seeded(null);

  @override
  void initState() {
    _accountRepo
      ..getUserProfileFromServer()
      ..fetchCurrentUserId();
    subscription = _accountRepo.getAccountAsStream().listen((event) {
      account.add(event);
    });
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
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
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
                                      style: theme.textTheme.headline6,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      snapshot.data!.username ?? "",
                                      style: theme.primaryTextTheme.subtitle1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      buildPhoneNumber(
                                        snapshot.data!.countryCode!,
                                        snapshot.data!.nationalNumber!,
                                      ),
                                      style: theme.textTheme.subtitle1,
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
                    ),
                  )
                ],
              ),
              Section(
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
                  StreamBuilder<bool>(
                    stream: _authRepo.isLocalLockEnabledStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && !(snapshot.data!)) {
                        return const SizedBox.shrink();
                      }
                      return SettingsTile(
                        title: _i18n.get("lock_app"),
                        leading: const Icon(CupertinoIcons.lock),
                        onPressed: (context) {
                          Navigator.pushReplacement(
                            _uxService.appContext,
                            MaterialPageRoute(
                              builder: (c) {
                                return const SplashScreen();
                              },
                            ),
                          );
                        },
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
                  if (_featureFlags.isVoiceCallAvailable())
                    SettingsTile(
                      title: _i18n.get("calls"),
                      leading: const Icon(CupertinoIcons.phone),
                      onPressed: (context) {
                        _routingService.openCallsList();
                      },
                    )
                ],
              ),
              Section(
                title: _i18n.get("user_experience"),
                children: [
                  SettingsTile.switchTile(
                    title: _i18n.get("notification"),
                    leading: const Icon(CupertinoIcons.bell),
                    switchValue: !_uxService.isAllNotificationDisabled,
                    onToggle: (value) => setState(
                      () => _uxService.toggleIsAllNotificationDisabled(),
                    ),
                  ),
                  if (isAndroid)
                    SettingsTile.switchTile(
                      title: _i18n.get("notification_advanced_mode"),
                      leading: const Icon(CupertinoIcons.bell_circle_fill),
                      switchValue:
                          !_uxService.isNotificationAdvanceModeDisabled,
                      onToggle: (value) => value
                          ? _showNotificationAdvanceModeDialog()
                          : setState(() {
                              _uxService
                                  .toggleIsAdvanceNotificationModeDisabled();
                            }),
                    ),
                  SettingsTile(
                    title: _i18n.get("language"),
                    subtitle: _i18n.locale.language().name,
                    leading: const FaIcon(FontAwesomeIcons.globe),
                    onPressed: (context) {
                      _routingService.openLanguageSettings();
                    },
                  ),
                  SettingsTile(
                    title: _i18n.get("security"),
                    leading: const Icon(CupertinoIcons.shield_lefthalf_fill),
                    onPressed: (context) =>
                        _routingService.openSecuritySettings(),
                    trailing: const SizedBox.shrink(),
                  ),
                  SettingsTile(
                    title: _i18n.get("devices"),
                    leading: const Icon(CupertinoIcons.device_desktop),
                    onPressed: (c) {
                      _routingService.openDevices();
                    },
                  ),
                  if (isDesktop)
                    SettingsTile.switchTile(
                      title: _i18n.get("send_by_shift_enter"),
                      leading: const Icon(CupertinoIcons.keyboard),
                      switchValue: !_uxService.sendByEnter,
                      onToggle: (value) {
                        setState(() => _uxService.toggleSendByEnter());
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
                    switchValue: _uxService.themeIsDark,
                    onToggle: (value) {
                      setState(() {
                        _uxService.toggleThemeLightingMode();
                      });
                    },
                  ),
                  SettingsTile(
                    title: _i18n.get("advanced_settings"),
                    leading: const Icon(CupertinoIcons.paintbrush),
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
                    subtitleTextStyle: TextStyle(
                      color: theme.primaryColor,
                    ),
                    leading: const Icon(CupertinoIcons.cloud_download),
                    onPressed: (context) => _routingService.openAutoDownload(),
                  ),
                  SettingsTile(
                    title: _i18n.get("connection_settings"),
                    subtitleTextStyle: TextStyle(
                      color: theme.primaryColor,
                    ),
                    leading: const Icon(CupertinoIcons.settings),
                    onPressed: (context) =>
                        _routingService.openConnectionSettingPage(),
                  ),
                ],
              ),
              if (UxService.showDeveloperPage)
                Section(
                  title: 'Developer Mode',
                  children: [
                    SettingsTile(
                      title: 'Developer Page',
                      subtitle: "Log Level: ${LogLevelHelper.levelToString(
                        GetIt.I.get<DeliverLogFilter>().level!,
                      )}",
                      leading: const Icon(Icons.bug_report_rounded),
                      onPressed: (context) {
                        _routingService.openDeveloperPage();
                      },
                    )
                  ],
                ),
              Section(
                children: [
                  if (_featureFlags.labIsAvailable())
                    SettingsTile(
                      title: _i18n.get("lab"),
                      subtitleTextStyle: TextStyle(color: theme.primaryColor),
                      leading: const FaIcon(FontAwesomeIcons.vial),
                      onPressed: (context) => _routingService.openLab(),
                    ),
                  SettingsTile(
                    title: _i18n.get("version"),
                    leading:
                        const Icon(CupertinoIcons.square_stack_3d_down_right),
                    trailing: UxService.showDeveloperPage
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
                          UxService.showDeveloperPage = true;
                        });
                      }
                    },
                  ),
                  SettingsTile(
                    title: _i18n.get("logout"),
                    leading: const Icon(CupertinoIcons.square_arrow_left),
                    onPressed: (context) =>
                        openLogoutAlertDialog(context, _i18n),
                    trailing: const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
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
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
          content: Text(
            _i18n.get("notification_advance_mode_description"),
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(c);
                if (await _backgroundService.enableListenOnSmsAnCall()) {
                  setState(() {
                    _uxService.toggleIsAdvanceNotificationModeDisabled();
                  });
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
          actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
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
