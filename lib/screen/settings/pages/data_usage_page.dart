import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:usage_stats/usage_stats.dart';

class DataUsagePage extends StatefulWidget {
  const DataUsagePage({Key? key}) : super(key: key);

  @override
  State<DataUsagePage> createState() => _DataUsagePageState();
}

class _DataUsagePageState extends State<DataUsagePage>
    with WidgetsBindingObserver {
  final _i18n = GetIt.I.get<I18N>();
  bool _permissionGranted = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    checkUsagePermission();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _permissionGranted = (await UsageStats.checkUsagePermission())!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 1));
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.get("devices")),
      ),
      body: !_permissionGranted
          ? generatePermissionWidget()
          : FutureBuilder<List<UsageInfo>>(
              future: UsageStats.queryUsageStats(startDate, endDate),
              builder: (context, eventUsageInfo) {
                if (eventUsageInfo.hasData &&
                    eventUsageInfo.data != null &&
                    eventUsageInfo.data!.isNotEmpty) {
                  return FutureBuilder<NetworkInfo>(
                    future:
                        UsageStats.queryNetworkUsageStats(startDate, endDate),
                    builder: (context, networkInfo) {
                      if (networkInfo.hasData && networkInfo.data != null) {
                        return buildUsageInformationWidget(
                          context,
                          eventUsageInfo.data!
                              .where(
                                (element) =>
                                    element.packageName == "ir.we.deliver",
                              )
                              .first,
                          networkInfo.data,
                        );
                      } else if (networkInfo.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                } else if (eventUsageInfo.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
    );
  }

  Future<void> checkUsagePermission() async {
    _permissionGranted = (await UsageStats.checkUsagePermission())!;
    setState(() {});
    if (!_permissionGranted) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            content: SizedBox(
              width: 200,
              child: Text(
                'for access to date usage you should permission to app to get the information please press the continue for generate permission',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await UsageStats.grantUsagePermission();
                  setState(() {});
                },
                child: Text(
                  _i18n.get("continue"),
                ),
              )
            ],
          );
        },
      );
    }
  }

  Widget buildUsageInformationWidget(
    BuildContext context,
    UsageInfo eventUsageInfo,
    NetworkInfo? networkInfo,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildInformationBox("Wifi Usage for last 30 days", [
            {
              "Send": networkInfo?.wifiStatsTxTotalBytes ?? "0",
            },
            {"Receive": networkInfo?.wifiStatsRxTotalBytes ?? "0"}
          ]),
          buildInformationBox("mobile Usage for last 30 days", [
            {
              "Send": networkInfo?.mobileStatsTxTotalBytes ?? "0",
            },
            {"Receive": networkInfo?.mobileStatsRxTotalBytes ?? "0"}
          ]),
          buildInformationBox("Time Usage for last 30 days", [
            {
              "First Time Stamp": DateTime.fromMillisecondsSinceEpoch(
                int.parse(eventUsageInfo.firstTimeStamp!),
              ).toString()
            },
            {
              "Last Time Stamp": DateTime.fromMillisecondsSinceEpoch(
                int.parse(eventUsageInfo.lastTimeStamp!),
              ).toString()
            },
            {
              "Last Time Used": DateTime.fromMillisecondsSinceEpoch(
                int.parse(eventUsageInfo.lastTimeUsed!),
              ).toString()
            },
            {
              "Total Time In Foreground":
                  (int.parse(eventUsageInfo.totalTimeInForeground!) / 1000 / 60)
                      .toString()
            }
          ]),
        ],
      ),
    );
  }

  Widget buildInformationBox(
    String title,
    List<Map<String, String>> row,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (c, index) {
                return ListTile(
                  title: Text(row[index].keys.first),
                  trailing: Text(row[index].values.first),
                );
              },
              itemCount: row.length,
              separatorBuilder: (c, i) {
                return const Divider();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget generatePermissionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("you dint access to app to get information"),
          TextButton(
            child: const Text("go to settings"),
            onPressed: () async {
              await checkUsagePermission();
            },
          )
        ],
      ),
    );
  }
}
