import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';

class AboutSoftwarePage extends StatefulWidget {
  const AboutSoftwarePage({super.key});

  @override
  AboutSoftwarePageState createState() => AboutSoftwarePageState();
}

class AboutSoftwarePageState extends State<AboutSoftwarePage> {
  final _routingService = GetIt.I.get<RoutingService>();
  int developerModeCounterCountDown = kDebugMode ? 1 : 10;
  final _coreServices = GetIt.I.get<CoreServices>();
  final _uptime = BehaviorSubject.seeded(0);
  final _i18n = GetIt.I.get<I18N>();
  late final Timer timerSubscription;

  @override
  void initState() {
    updateUptime();

    timerSubscription =
        Timer.periodic(const Duration(seconds: 1), (_) => updateUptime());
    super.initState();
  }

  void updateUptime() {
    final uptimeStartTime = _coreServices.uptimeStartTime.value;

    if (uptimeStartTime == 0) {
      _uptime.add(0);
    } else {
      _uptime.add(clock.now().millisecondsSinceEpoch - uptimeStartTime);
    }
  }

  @override
  void dispose() {
    timerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n["about_software"]),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            children: [
              FutureBuilder<String>(
                future: settings.showDeveloperPage.value
                    ? Future.value("")
                    : SmsAutoFill().getAppSignature,
                builder: (c, sms) => Section(
                  title: "Software information",
                  children: [
                    SettingsTile(
                      title: _i18n.get("version"),
                      subtitle: "v$VERSION",
                      leading: const Icon(
                        CupertinoIcons.square_stack_3d_down_right,
                      ),
                      onPressed: (_) async {
                        developerModeCounterCountDown--;
                        if (developerModeCounterCountDown < 1 &&
                            !settings.showDeveloperPage.value) {
                          setState(() {
                            settings.showDeveloperPage.set(true);

                            ToastDisplay.showToast(
                              toastContext: context,
                              showWarningAnimation: true,
                              toastText: "Developer Page enabled",
                            );
                          });
                        }
                      },
                      trailing: const SizedBox.shrink(),
                    ),
                    const SettingsTile(
                      title: "Build Number",
                      subtitle: BUILD_NUMBER,
                      leading: Icon(CupertinoIcons.number_square),
                      trailing: SizedBox.shrink(),
                    ),
                    const SettingsTile(
                      title: "Install From",
                      subtitle: INSTALL_FROM,
                      leading: Icon(Icons.shopping_basket_outlined),
                      trailing: SizedBox.shrink(),
                    ),
                    SettingsTile(
                      title: "Connection Uptime",
                      leading: const Icon(CupertinoIcons.time),
                      trailing: StreamBuilder<int>(
                        stream: _uptime,
                        builder: (context, snapshot) {
                          final duration =
                              Duration(milliseconds: snapshot.data ?? 0);

                          return Text(duration.toString().split(".")[0]);
                        },
                      ),
                    ),
                    SettingsTile(
                      title: "Connection Establishment Count",
                      leading: const Icon(Icons.network_check),
                      trailing: StreamBuilder<int>(
                        stream: _coreServices.reconnectCount,
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;

                          return Text(count.toString());
                        },
                      ),
                    ),
                    if (settings.showDeveloperPage.value)
                      SettingsTile(
                        title: "App signature",
                        leading: const Icon(CupertinoIcons.signature),
                        trailing: Text(
                          (sms.data == null || (sms.data?.isEmpty ?? true))
                              ? "No signature data available"
                              : sms.data!,
                        ),
                      ),
                  ],
                ),
              ),
              Section(
                title: _i18n["about_update"],
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(vertical: p8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: _i18n.changelogs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: p12,
                            vertical: p2,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${index + 1}. "),
                              Expanded(
                                child: Text(
                                  _i18n.changelogs[index],
                                  textDirection: _i18n.defaultTextDirection,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
