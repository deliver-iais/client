import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
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
  final _callRepo = GetIt.I.get<CallRepo>();
  final _sharedDao = GetIt.I.get<SharedDao>();

  double ICECandidateNumber = 5;

  double ICECandidateTimeLimit = 500;

  List<CheckBoxListTileModel> checkBoxListTileModel = [];

  @override
  void initState() {
    getCandidateValues();
    getICEServersValues();
    super.initState();
  }

  Future<void> getCandidateValues() async {
    ICECandidateNumber =
        double.parse(await _sharedDao.get("ICECandidateNumbers") ?? "5");
    ICECandidateTimeLimit = double.parse(
        await _sharedDao.get("ICECandidateTimeLimit") ?? "500"); //mSec
    setState(() {});
  }

  Future<void> getICEServersValues() async {
    checkBoxListTileModel = await getServers();
    setState(() {});
  }

  void itemChange(bool val, int index) {
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
      _featureFlags.setICEServerEnable(checkBoxListTileModel[index].title, val);
    });
  }

  Future<void> checkForSystemAlertWindowPermission() async {
    if (isAndroid &&
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
                          setState(() {});
                        },
                      );
                    },
                  ),
                  if (_featureFlags.isVoiceCallAvailable())
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
                          divisions: 15,
                          label: "$ICECandidateNumber",
                          min: 5,
                          max: 20,
                        )
                      ],
                    ),
                  if (_featureFlags.isVoiceCallAvailable())
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
                          divisions: 45,
                          label: "$ICECandidateTimeLimit",
                          min: 500,
                          max: 5000,
                        )
                      ],
                    ),
                  if (_featureFlags.isVoiceCallAvailable())
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
                                          itemChange(val!, index);
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
              if (_featureFlags.isVoiceCallAvailable())
                Section(
                  title: "Call Logs",
                  children: [
                    Column(
                      children: [
                        SettingsTile(
                          title: "SelectedCandidate",
                          leading: const Icon(
                              CupertinoIcons.check_mark_circled_solid),
                          trailing: TextButton(
                            onPressed: () async {
                              await _callRepo.reset();
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).errorColor,
                            ),
                            child: const Text("Logs Reset"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("id"),
                                        Text(_callRepo.selectedCandidate.id),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("timestamp"),
                                        Text(_callRepo
                                            .selectedCandidate.timestamp
                                            .toString()),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("type"),
                                        Text(_callRepo.selectedCandidate.type),
                                      ],
                                    ),
                                    ..._callRepo
                                        .selectedCandidate.values.entries
                                        .map(
                                          (entry) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(entry.key),
                                              Text(
                                                entry.value.toString(),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SettingsTile(
                          title: "Last Call Events",
                          leading: Icon(CupertinoIcons.pencil_outline),
                          trailing: Text(""),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Column(
                                  children: [
                                    ..._callRepo.callEvents.entries
                                        .map(
                                          (entry) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(entry.key.toString()),
                                              Text(
                                                entry.value,
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
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
        isCheck: await _sharedDao.getBoolean("stun:217.218.7.16:3478", defaultValue : true),
      ),
      CheckBoxListTileModel(
        checkboxId: 3,
        title: "turn:217.218.7.16:3478?transport=udp",
        isCheck: await _sharedDao.getBoolean("turn:217.218.7.16:3478?transport=udp", defaultValue : true),
      ),
      CheckBoxListTileModel(
        checkboxId: 2,
        title: "stun:stun.l.google.com:19302",
        isCheck: await _sharedDao.getBoolean("stun:stun.l.google.com:19302"),
      ),
      CheckBoxListTileModel(
        checkboxId: 4,
        title: "turn:47.102.201.4:19303?transport=udp",
        isCheck: await _sharedDao.getBoolean("turn:47.102.201.4:19303?transport=udp"),
      ),
    ];
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Tgs.asset(
            'assets/animations/call_permission.tgs',
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
                style: theme.textTheme.bodyText1!
                    .copyWith(color: theme.primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _i18n.get(
                    "alert_window_permission_attention",
                  ),
                  textDirection: _i18n.defaultTextDirection,
                  style: theme.textTheme.bodyText1!
                      .copyWith(color: theme.errorColor),
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
                foregroundColor: Theme.of(context).errorColor,
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
                  Navigator.of(context).pop();
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
  final _sharedDao = GetIt.I.get<SharedDao>();

  CheckBoxListTileModel(
      {required this.checkboxId, required this.title, required this.isCheck});
}
