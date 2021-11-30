import 'package:deliver/services/routing_service.dart';

import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:settings_ui/settings_ui.dart';

class LogSettingsPage extends StatefulWidget {
  const LogSettingsPage({Key? key}) : super(key: key);

  @override
  _LogSettingsPageState createState() => _LogSettingsPageState();
}

class _LogSettingsPageState extends State<LogSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _uxService = GetIt.I.get<UxService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              titleSpacing: 8,
              title: const Text("Log Level"),
              leading: _routingService.backButtonLeading(context),
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: SettingsList(
            sections: [
              SettingsSection(
                title: 'Log Levels',
                tiles: LogLevelHelper.levels()
                    .map((level) => SettingsTile(
                          title: level,
                          trailing: LogLevelHelper.stringToLevel(level) ==
                                  GetIt.I.get<DeliverLogFilter>().level
                              ? const Icon(Icons.done)
                              : const SizedBox.shrink(),
                          onPressed: (BuildContext context) {
                            setState(() {
                              _uxService.changeLogLevel(level);
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ));
  }
}
