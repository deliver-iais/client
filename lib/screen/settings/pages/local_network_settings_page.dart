import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class LocalNetworkSettingsPage extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();

  LocalNetworkSettingsPage({super.key});

  final _superNode = (settings.isSuperNode.value).obs;
  final _backUp = (settings.backupLocalNetworkMessages.value).obs;
  final _serverLessService = GetIt.I.get<ServerLessService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.get("local_network_settings")),
      ),
      body: Center(
        child: FluidContainerWidget(
          child: ListView(
            shrinkWrap: true,
            children: [
              Obx(
                () => Section(
                  children: [
                    Column(
                      children: [
                        SettingsTile.switchTile(
                          title: _i18n.get("super_node"),
                          leading:
                              const Icon(Icons.settings_input_antenna_rounded),
                          switchValue: _superNode.value,
                          onToggle: ({required newValue}) {
                            _superNode.value = newValue;
                            settings.isSuperNode.set(newValue);
                            _serverLessService.sendBroadCast();
                          },
                        ),
                        const Divider(),
                        SettingsTile.switchTile(
                          title: _i18n.get("backup_local_network_messages"),
                          leading: const Icon(Icons.backup_outlined),
                          switchValue: _backUp.value,
                          onToggle: ({required newValue}) {
                            _backUp.value = newValue;
                            settings.backupLocalNetworkMessages.set(newValue);
                          },
                        ),
                        // SettingsTile.switchTile(
                        //   title: _i18n.get(
                        //       "send_to_server_after_one_try_on_internal_network"),
                        //   leading: const Icon(Cupert),
                        //   switchValue: _backUp.value,
                        //   onToggle: ({required newValue}) {
                        //     _backUp.value = newValue;
                        //     settings.backupLocalNetworkMessages.set(newValue);
                        //   },
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
