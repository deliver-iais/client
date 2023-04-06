import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/brand_image.dart';
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

  List<CallServerItem> checkBoxListTileModel = [
    CallServerItem(
      checkboxId: 1,
      serverSetting: settings.localStunServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 2,
      serverSetting: settings.localTurnServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 3,
      serverSetting: settings.googleStunServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 4,
      serverSetting: settings.googleTurnServerIsEnabled,
    ),
  ];

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
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: ListView(
            children: [
              BrandImage(
                text: _i18n.get("these_feature_arent_stable_yet"),
                imagePath: "assets/images/experiment.webp",
                alignment: Alignment.topCenter,
              ),
              if (hasForegroundServiceCapability)
                Section(
                  title: 'Foreground Service',
                  children: [
                    SettingsTile.switchTile(
                      title: "Foreground Notification Enable",
                      subtitle:
                          "Application will be available in background for getting new messages online",
                      switchValue:
                          settings.foregroundNotificationIsEnabled.value,
                      onToggle: (value) {
                        setState(() {
                          settings.foregroundNotificationIsEnabled
                              .toggleValue();
                        });
                      },
                    ),
                  ],
                ),
              if (_featureFlags.isVoiceCallAvailable())
                Section(
                  title: _i18n.get("calls"),
                  children: [
                    SettingsTile(
                      title: _i18n.get("voice_call_feature"),
                      leading: const Icon(CupertinoIcons.phone_circle),
                      trailing: const SizedBox.shrink(),
                    ),
                    Column(
                      children: [
                        const SettingsTile(
                          title: "ICECandidateNumber",
                          leading: Icon(CupertinoIcons.number_square_fill),
                          trailing: Text(""),
                        ),
                        Slider(
                          value: settings.iceCandidateNumbers.value.toDouble(),
                          onChanged: (newICECandidateNumber) {
                            setState(() {
                              settings.iceCandidateNumbers
                                  .set(newICECandidateNumber.toInt());
                            });
                          },
                          divisions: 5,
                          label: "${settings.iceCandidateNumbers.value}",
                          min: ICE_CANDIDATE_NUMBER.toDouble(),
                          max: 20,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        const SettingsTile(
                          title: "ICECandidateTimeLimit(mSec)",
                          leading: Icon(CupertinoIcons.timer_fill),
                          trailing: Text(""),
                        ),
                        Slider(
                          value:
                              settings.iceCandidateTimeLimit.value.toDouble(),
                          onChanged: (newICECandidateTimeLimit) {
                            setState(() {
                              settings.iceCandidateTimeLimit.set(
                                newICECandidateTimeLimit.toInt(),
                              );
                            });
                          },
                          divisions: 15,
                          label: "${settings.iceCandidateTimeLimit.value}",
                          min: ICE_CANDIDATE_TIME_LIMIT.toDouble(),
                          max: 3000,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        const SettingsTile(
                          title: "Turn/Stun Servers",
                          leading: Icon(CupertinoIcons.settings),
                          trailing: Text(""),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: checkBoxListTileModel.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: <Widget>[
                                      CheckboxListTile(
                                        activeColor: theme.colorScheme.primary,
                                        dense: true,
                                        //font change
                                        title: Text(
                                          checkBoxListTileModel[index]
                                              .serverSetting
                                              .name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        value: checkBoxListTileModel[index]
                                            .serverSetting
                                            .value,
                                        onChanged: (_) {
                                          setState(() {
                                            checkBoxListTileModel[index]
                                                .serverSetting
                                                .toggleValue();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CallServerItem {
  int checkboxId;
  BooleanPersistent serverSetting;

  CallServerItem({
    required this.checkboxId,
    required this.serverSetting,
  });
}
