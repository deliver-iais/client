import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/box/query_log.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/ext_storage_services.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/log.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:share/share.dart';

import '../../../box/dao/query_log_dao.dart';
import '../../../box/db_manager.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  DeveloperPageState createState() => DeveloperPageState();
}

class DeveloperPageState extends State<DeveloperPage> with CustomPopupMenu {
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _fileService = GetIt.I.get<FileService>();
  final  _queryLogDao = GetIt.I.get<QueryLogDao>();


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
                  switchValue: settings.showDeveloperDetails.value,
                  onToggle: ({required newValue}) {
                    setState(() {
                      settings.showDeveloperDetails.toggleValue();
                    });
                  },
                ),
              ],
            ),
            Section(
              title: 'Log Levels',
              children: Level.values
                  .map(
                    (level) => SettingsTile(
                      title: level.name,
                      leading: Icon(
                        level == GetIt.I.get<DeliverLogFilter>().level
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: const SizedBox.shrink(),
                      onPressed: (context) {
                        setState(() => settings.logLevel.set(level));
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
                  switchValue: settings.logInFileEnable.value,
                  onToggle: ({required newValue}) {
                    setState(() => settings.logInFileEnable.toggleValue());
                  },
                ),
                Column(
                  children: [
                    GestureDetector(
                      onPanDown: storeDragDownPosition,
                      child: SettingsTile(
                        title: "Share Log File",
                        onPressed: (c) {
                          this.showMenu(
                            context: context,
                            items: [
                              PopupMenuItem<String>(
                                key: const Key("send"),
                                value: "send",
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.send,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _i18n.get("send"),
                                    )
                                  ],
                                ),
                              ),
                              if (isMobileNative)
                                PopupMenuItem<String>(
                                  key: const Key("share"),
                                  value: "share",
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.share,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_i18n.get("share")),
                                    ],
                                  ),
                                ),
                              PopupMenuItem<String>(
                                key: const Key("save_to_downloads"),
                                value: "save_to_downloads",
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.arrow_down_circle,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _i18n.get("save_to_downloads"),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ).then(
                            (value) => _selectContactMenu(value ?? ""),
                          );
                        },
                      ),
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
                title: "Call Events",
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
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: const Text("Logs Reset"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                          end: 24,
                          start: 24,
                          bottom: 10,
                        ),
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
                    ],
                  ),
                  Column(
                    children: [
                      const SettingsTile(
                        title: "Last Call Events",
                        leading: Icon(CupertinoIcons.pencil_outline),
                        trailing: Text(""),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsetsDirectional.only(
                          end: 24,
                          start: 24,
                          bottom: 10,
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
                    ],
                  ),
                ],
              ),
            Section(
              title: "Authentication",
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    // runSpacing: 8,
                    children: [
                      Debug(
                        _authRepo.refreshToken(),
                        label: "Refresh Token",
                      ),
                      Debug(
                        _authRepo.accessToken,
                        label: "Access Token",
                      ),
                      Debug(
                        _authRepo.serverTimeDiff,
                        label: "Server time diff",
                      ),
                      Debug(
                        clock.now(),
                        label: "App time",
                      ),
                      Debug(
                        clock.now().millisecondsSinceEpoch,
                        label: "App time in milliseconds since epoch time",
                      ),
                      Debug(
                        JwtDecoder.getExpirationDate(_authRepo.refreshToken()),
                        label: "Refresh Token Expire Date",
                      ),
                      Debug(
                        JwtDecoder.getExpirationDate(_authRepo.accessToken),
                        label: "Access Token Expire Date",
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (hasFirebaseCapability)
              Section(
                title: "Firebase Token",
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      runSpacing: 8,
                      children: [
                        Debug(
                          settings.firebaseToken.value,
                          label: "Token",
                        ),
                      ],
                    ),
                  )
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
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.2)
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
              title: "Analytics - Query Log",
              children: [
                StreamBuilder(
                  stream: _queryLogDao.watchQueryLogs().asBroadcastStream(),
                  builder: (context, snapshot) {
                    return Table(
                      border: TableBorder.all(borderRadius: mainBorder),
                      columnWidths: const {
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.2)
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
                        in snapshot.data ?? [])
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8,
                                  ),
                                  child: Text(e.address),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text((e.count).toString()),
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
              title: "Analytics - Core Stream Packets Frequency",
              children: [
                StreamBuilder(
                  stream: _analyticsRepo.coreStreamEvents,
                  builder: (context, snapshot) {
                    return Table(
                      border: TableBorder.all(borderRadius: mainBorder),
                      columnWidths: const {
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.2)
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
                                child: Text("Packet Type"),
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
                            in _analyticsRepo.coreStreamPacketFrequency.entries)
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
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.2)
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
                        0: FlexColumnWidth(0.8),
                        1: FlexColumnWidth(0.2)
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectContactMenu(String key) async {
    final path = await GetIt.I.get<DeliverLogOutput>().getLogFilePath();
    const name = "log.txt";
    switch (key) {
      case "share":
        await Share.shareFiles([path]);
        break;
      case "send":
        final copiedFilePath = await _fileService.saveFileInAppDirectory(
          File(path),
          "my_log",
          "txt",
        );
        _routingService.openShareInput(paths: [copiedFilePath]);
        break;
      case "save_to_downloads":
        await (isDesktopNative
            ? _fileService.saveFileInDesktopDownloadFolder(name, path)
            : _fileService.saveFileInMobileDownloadFolder(
                path,
                name,
                ExtStorage.download,
              ));
        if (context.mounted) {
          ToastDisplay.showToast(
            toastContext: context,
            toastText: _i18n.get("file_saved"),
            showDoneAnimation: true,
          );
        }

        break;
    }
  }
}
