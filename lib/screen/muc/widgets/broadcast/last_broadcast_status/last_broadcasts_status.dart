import 'package:deliver/box/broadcast_success_and_failed_count.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/gradiant_circle_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LastBroadcastsStatus extends StatelessWidget {
  final String broadcastRoomId;
  static final _broadcastService = GetIt.I.get<BroadcastService>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();

  const LastBroadcastsStatus({Key? key, required this.broadcastRoomId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: FutureBuilder<List<BroadcastSuccessAndFailedCount>>(
        future: _broadcastService
            .getAllBroadcastSuccessAndFailedCount(broadcastRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final allBroadcastSuccessAndFailedCount =
                snapshot.data!.reversed.toList();
            if (allBroadcastSuccessAndFailedCount.isNotEmpty) {
              return Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal:p8),
                child: ListView.builder(
                  itemCount: allBroadcastSuccessAndFailedCount.length,
                  itemBuilder: (context, index) {
                    final lastBroadcastStatus =
                        allBroadcastSuccessAndFailedCount[index];
                    final progress = lastBroadcastStatus.broadcastSuccessCount /
                        (lastBroadcastStatus.broadcastFailedCount +
                            lastBroadcastStatus.broadcastSuccessCount);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(p8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 75,
                              height: 75,
                              child: CustomPaint(
                                size: const Size(75, 75),
                                painter: GradiantCircleProgressBar(
                                  inactiveColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  progressValue: progress,
                                  borderThickness: 10,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.inversePrimary,
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "${(progress * 100).toInt()}%",
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                children: [
                                  Text(
                                    "${_i18n.get("successful_count")} : ${lastBroadcastStatus.broadcastSuccessCount}",
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: p8,
                                    ),
                                    child: Text(
                                      "${_i18n.get("failures_count")} : ${lastBroadcastStatus.broadcastFailedCount}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _routingService.openRoom(
                                broadcastRoomId,
                                initialIndex:
                                    lastBroadcastStatus.broadcastMessageId,
                              ),
                              child: Text(_i18n.get("show_message")),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(p8),
                child: NoResultWidget(
                  text: _i18n.get("no_last_broadcast"),
                ),
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
