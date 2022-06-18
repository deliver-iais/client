import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LabSettingsPage extends StatefulWidget {
  const LabSettingsPage({super.key});

  @override
  State<LabSettingsPage> createState() => _LabSettingsPageState();
}

class _LabSettingsPageState extends State<LabSettingsPage> {
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("lab")),
        ),
      ),
      body: FluidContainerWidget(
        child: ListView(
          children: [
            Card(
              color: theme.colorScheme.errorContainer,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(_i18n.get("these_feature_arent_stable_yet")),
              ),
            ),
            Section(
              title: _i18n.get("calls"),
              children: [
                StreamBuilder<bool>(
                  stream: _featureFlags.voiceCallFeatureFlagStream,
                  builder: (context, snapshot) {
                    return SettingsTile.switchTile(
                      title: _i18n.get("voice_call_feature"),
                      leading: const Icon(CupertinoIcons.phone),
                      switchValue: snapshot.data ?? false,
                      onToggle: (value) {
                        _featureFlags.toggleVoiceCallFeatureFlag();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
