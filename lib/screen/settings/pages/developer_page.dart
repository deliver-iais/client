import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/log.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  DeveloperPageState createState() => DeveloperPageState();
}

class DeveloperPageState extends State<DeveloperPage> {
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _uxService = GetIt.I.get<UxService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();
  final _shareDao = GetIt.I.get<SharedDao>();
  final _callRepo = GetIt.I.get<CallRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: const Text("Developer Page"),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: ListView(
          children: [
            Section(
              title: 'Developer Options',
              children: [
                SettingsTile.switchTile(
                  title: "Show Special Debugging Details",
                  switchValue: _featureFlags.showDeveloperDetails,
                  onToggle: (value) {
                    setState(() {
                      _featureFlags.toggleShowDeveloperDetails();
                    });
                  },
                ),
              ],
            ),
            Section(
              title: 'Log Levels',
              children: LogLevelHelper.levels()
                  .map(
                    (level) => SettingsTile(
                      title: level,
                      trailing: LogLevelHelper.stringToLevel(level) ==
                              GetIt.I.get<DeliverLogFilter>().level
                          ? const Icon(Icons.done)
                          : const SizedBox.shrink(),
                      onPressed: (context) {
                        setState(() {
                          _uxService.changeLogLevel(level);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            Section(
              title: "Log in File",
              children: [
                SettingsTile.switchTile(
                  title: "Log in file is Enabled",
                  switchValue:
                      GetIt.I.get<DeliverLogOutput>().saveInFileIsEnabled,
                  onToggle: (value) {
                    setState(() {
                      _uxService.toggleLogInFileEnable();
                    });
                  },
                ),
                Column(
                  children: [
                    SettingsTile(
                      title: "Share Log File",
                      onPressed: (context) async {
                        final path = await GetIt.I
                            .get<DeliverLogOutput>()
                            .getLogFilePath();

                        _routingService.openShareInput(paths: [path]);
                      },
                    ),
                    const Text(
                      "You can share your log file with us for debugging and later improvements",
                    ),
                  ],
                )
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
                          CupertinoIcons.check_mark_circled_solid,
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await _callRepo.reset();
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.errorColor,
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
                                      Text(
                                        _callRepo.selectedCandidate.timestamp
                                            .toString(),
                                      ),
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
                                  ..._callRepo.selectedCandidate.values.entries
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
              ),
            Section(
              title: "Analytics - Requests Frequency",
              children: [
                StreamBuilder(
                  stream: _analyticsRepo.events,
                  builder: (context, snapshot) {
                    return Table(
                      border: TableBorder.all(borderRadius: mainBorder),
                      columnWidths: const {
                        0: FlexColumnWidth(0.80),
                        1: FlexColumnWidth(0.20)
                      },
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8,
                                ),
                                child: Text("Grpc Path"),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8,
                                ),
                                child: Text("Frequency"),
                              ),
                            )
                          ],
                        ),
                        for (final e
                            in _analyticsRepo.requestsFrequency.entries)
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8,
                                  ),
                                  child: Text(e.key),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(e.value.toString()),
                                ),
                              )
                            ],
                          )
                      ],
                    );
                  },
                )
              ],
            ),
            Section(
              title: "Analytics - Dao Frequency",
              children: [
                StreamBuilder(
                  stream: _analyticsRepo.daoEvents,
                  builder: (context, snapshot) {
                    return Table(
                      border: TableBorder.all(borderRadius: mainBorder),
                      columnWidths: const {
                        0: FlexColumnWidth(0.80),
                        1: FlexColumnWidth(0.20)
                      },
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8,
                                ),
                                child: Text("Dao Action"),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8,
                                ),
                                child: Text("Frequency"),
                              ),
                            )
                          ],
                        ),
                        for (final e in _analyticsRepo.daoFrequency.entries)
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8,
                                  ),
                                  child: Text(e.key),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(e.value.toString()),
                                ),
                              )
                            ],
                          )
                      ],
                    );
                  },
                )
              ],
            ),
            Section(
              title: "Analytics - Page View Frequency",
              children: [
                StreamBuilder(
                  stream: _analyticsRepo.events,
                  builder: (context, snapshot) {
                    return Table(
                      border: TableBorder.all(borderRadius: mainBorder),
                      columnWidths: const {
                        0: FlexColumnWidth(0.80),
                        1: FlexColumnWidth(0.20)
                      },
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 8,
                                ),
                                child: Text("Path"),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8,
                                ),
                                child: Text("Frequency"),
                              ),
                            )
                          ],
                        ),
                        for (final e
                            in _analyticsRepo.pageViewFrequency.entries)
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8,
                                  ),
                                  child: Text(e.key),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(e.value.toString()),
                                ),
                              )
                            ],
                          )
                      ],
                    );
                  },
                )
              ],
            ),
            Section(
              title: "Tokens",
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    runSpacing: 8,
                    children: [
                      Debug(
                        _authRepo.refreshToken,
                        label: "Refresh Token",
                      ),
                      Debug(
                        _authRepo.refreshToken,
                        label: "Access Token",
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (hasFirebaseCapability)
              FutureBuilder<String?>(
                future: _shareDao.get(SHARED_DAO_FIREBASE_TOKEN),
                builder: (c, ft) {
                  if (ft.hasData && ft.data != null) {
                    return Section(
                      title: "Firebase Token",
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            runSpacing: 8,
                            children: [
                              Debug(
                                ft.data,
                                label: "Token",
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}
