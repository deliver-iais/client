import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/routing_service.dart';

import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({Key? key}) : super(key: key);

  @override
  _DeveloperPageState createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _uxService = GetIt.I.get<UxService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UltimateAppBar(
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
            )
          ],
        ),
      ),
    );
  }
}
