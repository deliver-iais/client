import 'dart:math';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/brand_image.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class LabSettingsPage extends StatefulWidget {
  const LabSettingsPage({super.key});

  @override
  State<LabSettingsPage> createState() => _LabSettingsPageState();
}

class _LabSettingsPageState extends State<LabSettingsPage> {
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _i18n = GetIt.I.get<I18N>();
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _notificationForegroundService =
      GetIt.I.get<NotificationForegroundService>();

  double ICECandidateNumber = ICE_CANDIDATE_NUMBER;

  double ICECandidateTimeLimit = ICE_CANDIDATE_TIME_LIMIT;

  List<CheckBoxListTileModel> checkBoxListTileModel = [];

  @override
  void initState() {
    getCandidateValues();
    getICEServersValues();
    super.initState();
  }

  Future<void> getCandidateValues() async {
    ICECandidateNumber = max(
      double.parse(
        await _sharedDao.get("ICECandidateNumbers") ??
            ICE_CANDIDATE_NUMBER.toString(),
      ),
      ICECandidateNumber,
    );
    ICECandidateTimeLimit = max(
      double.parse(
        await _sharedDao.get("ICECandidateTimeLimit") ??
            ICE_CANDIDATE_TIME_LIMIT.toString(),
      ),
      ICECandidateTimeLimit,
    ); //mSec
    setState(() {});
  }

  Future<void> getICEServersValues() async {
    checkBoxListTileModel = await getServers();
    setState(() {});
  }

  void changeStunAndTurnServerEnabledStatus(
    int index, {
    bool newValue = false,
  }) {
    setState(() {
      checkBoxListTileModel[index].isCheck = newValue;
      _featureFlags.setICEServerEnable(
        checkBoxListTileModel[index].title,
        newStatus: newValue,
      );
    });
  }

  Future<void> checkForSystemAlertWindowPermission() async {
    if (isAndroidNative &&
        await getDeviceVersion() >= 31 &&
        !await Permission.systemAlertWindow.status.isGranted) {
      showPermissionDialog();
    }
  }

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
                          _notificationForegroundService.foregroundNotification,
                      onToggle: (value) {
                        setState(() {
                          _notificationForegroundService
                              .toggleForegroundService();
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
                      leading: const Icon(CupertinoIcons.phone),
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
                          value: ICECandidateNumber,
                          onChanged: (newICECandidateNumber) {
                            setState(() {
                              ICECandidateNumber = newICECandidateNumber;
                              _featureFlags
                                  .setICECandidateNumber(ICECandidateNumber);
                            });
                          },
                          divisions: 5,
                          label: "$ICECandidateNumber",
                          min: ICE_CANDIDATE_NUMBER,
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
                          value: ICECandidateTimeLimit,
                          onChanged: (newICECandidateTimeLimit) {
                            setState(() {
                              ICECandidateTimeLimit = newICECandidateTimeLimit;
                              _featureFlags.setICECandidateTimeLimit(
                                ICECandidateTimeLimit,
                              );
                            });
                          },
                          divisions: 15,
                          label: "$ICECandidateTimeLimit",
                          min: ICE_CANDIDATE_TIME_LIMIT,
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
                                          checkBoxListTileModel[index].title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        value: checkBoxListTileModel[index]
                                            .isCheck,
                                        onChanged: (val) {
                                          changeStunAndTurnServerEnabledStatus(
                                            index,
                                            newValue: val ?? false,
                                          );
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

  Future<List<CheckBoxListTileModel>> getServers() async {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
        checkboxId: 1,
        title: "stun:217.218.7.16:3478",
        isCheck: await _sharedDao.getBoolean(
          "stun:217.218.7.16:3478",
          defaultValue: true,
        ),
      ),
      CheckBoxListTileModel(
        checkboxId: 3,
        title: "turn:217.218.7.16:3478?transport=udp",
        isCheck: await _sharedDao.getBoolean(
          "turn:217.218.7.16:3478?transport=udp",
          defaultValue: true,
        ),
      ),
      CheckBoxListTileModel(
        checkboxId: 2,
        title: "stun:stun.l.google.com:19302",
        isCheck: await _sharedDao.getBoolean(
          "stun:stun.l.google.com:19302",
          defaultValue: true,
        ),
      ),
      CheckBoxListTileModel(
        checkboxId: 4,
        title: "turn:47.102.201.4:19303?transport=udp",
        isCheck: await _sharedDao.getBoolean(
          "turn:47.102.201.4:19303?transport=udp",
          defaultValue: true,
        ),
      ),
    ];
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Ws.asset(
            'assets/animations/call_permission.ws',
            width: 150,
            height: 150,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _i18n.get(
                  "alert_window_permission",
                ),
                textDirection: _i18n.defaultTextDirection,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection: _i18n.defaultTextDirection,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.colorScheme.error),
                ),
              )
            ],
          ),
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                _i18n.get(
                  "cancel",
                ),
              ),
            ),
            TextButton(
              child: Text(
                _i18n.get("go_to_setting"),
              ),
              onPressed: () async {
                if (await Permission.systemAlertWindow.request().isGranted) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class CheckBoxListTileModel {
  int checkboxId;
  String title;
  bool isCheck;

  CheckBoxListTileModel({
    required this.checkboxId,
    required this.title,
    required this.isCheck,
  });
}
