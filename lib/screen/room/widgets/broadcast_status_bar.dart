import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class BroadcastStatusBar extends StatelessWidget {
  final Uid roomUid;
  final Widget inputMessage;
  static final broadcastService = GetIt.I.get<BroadcastService>();
  static final _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18N = GetIt.I.get<I18N>();
  static final _mucDao = GetIt.I.get<MucDao>();

  const BroadcastStatusBar({
    Key? key,
    required this.roomUid,
    required this.inputMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BroadcastRunningStatus>(
      stream: broadcastService.getBroadcastRunningStatus(roomUid),
      builder: (context, runningStatus) {
        return StreamBuilder<List<BroadcastStatus>>(
          stream: broadcastService.getAllBroadcastStatusAsStream(roomUid),
          builder: (context, snapshot) {
            final broadcastStatusList = snapshot.data;
            final waitingBroadcasts = broadcastStatusList
                ?.where(
                  (element) =>
                      element.status == BroadcastMessageStatusType.WAITING,
                )
                .toList();
            final failedBroadcasts = broadcastStatusList
                ?.where(
                  (element) =>
                      element.status == BroadcastMessageStatusType.FAILED,
                )
                .toList();
            final broadcastRunningStatus =
                broadcastService.getBroadcastRunningStatusDependOnWaitingCount(
              runningStatus.data,
              waitingBroadcasts?.length ?? 0,
            );
            final shouldShowBroadcastBar =
                broadcastRunningStatus == BroadcastRunningStatus.RUNNING ||
                    (broadcastStatusList?.isNotEmpty ?? false);

            return AnimatedSwitcher(
              duration: AnimationSettings.standard,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: AnimatedSize(
                    duration: AnimationSettings.slow,
                    curve: Curves.easeInOut,
                    child: child,
                  ),
                );
              },
              child: shouldShowBroadcastBar
                  ? _buildBroadcastStatusBar(
                      waitingBroadcasts!,
                      failedBroadcasts!,
                      broadcastRunningStatus,
                      broadcastStatusList!.length,
                      context,
                    )
                  : StreamBuilder<List<PendingMessage>>(
                      stream: _pendingMessageDao
                          .watchPendingMessages(roomUid)
                          .debounceTime(const Duration(milliseconds: 250)),
                      builder: (context, snapshot) {
                        if (snapshot.data?.isNotEmpty ?? false) {
                          return Container(
                            padding: const EdgeInsets.all(p8),
                            color: Theme.of(context).colorScheme.surface,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    _i18N.get(
                                      "you_already_have_pending_broadcast",
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _messageRepo.onDeletePendingMessage(
                                      snapshot.data!.first.msg,
                                    );
                                    _pendingMessageDao
                                        .deleteAllPendingMessageForRoom(
                                      roomUid,
                                    );
                                  },
                                  child: Text(_i18N.get("delete")),
                                ),
                              ],
                            ),
                          );
                        }
                        return inputMessage;
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildBroadcastStatusBar(
    List<BroadcastStatus> waitingBroadcasts,
    List<BroadcastStatus> failedBroadcasts,
    BroadcastRunningStatus broadcastRunningStatus,
    int broadcastStatusListLength,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return FutureBuilder<int>(
      key: const Key("_buildBroadcastStatusBar"),
      future: _mucDao.getBroadCastAllMemberCount(roomUid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! > 1) {
          final allMemberCount = snapshot.data!;
          final progressValue =
              1 - ((broadcastStatusListLength) / (allMemberCount));
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TweenAnimationBuilder<double>(
                        duration: AnimationSettings.verySlow,
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: progressValue,
                          end: progressValue,
                        ),
                        builder: (context, progress, _) => AnimatedContainer(
                          duration: AnimationSettings.verySlow,
                          decoration: BoxDecoration(
                            borderRadius: tertiaryBorder,
                            gradient: LinearGradient(
                              colors: broadcastRunningStatus !=
                                      BroadcastRunningStatus.END
                                  ? [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.inversePrimary,
                                      theme.colorScheme.onInverseSurface
                                    ]
                                  : [
                                      theme.colorScheme.error,
                                      theme.colorScheme.errorContainer,
                                      theme.colorScheme.onInverseSurface
                                    ],
                              stops: [
                                progress / 2,
                                progress,
                                progress,
                              ],
                            ),
                          ),
                          child: SizedBox(
                            height: 25,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                curve: Curves.bounceOut,
                                duration: AnimationSettings.actualStandard,
                                style: TextStyle(
                                  color: broadcastRunningStatus !=
                                          BroadcastRunningStatus.END
                                      ? progress < 0.55
                                          ? theme.colorScheme.inverseSurface
                                              .withOpacity(0.6)
                                          : theme.colorScheme.primaryContainer
                                      : progress < 0.55
                                          ? theme.colorScheme.error
                                              .withOpacity(0.6)
                                          : theme.colorScheme.errorContainer,
                                ),
                                child: Text(
                                  "${(progress * 100).toInt()}%",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () =>
                        _routingService.openBroadcastStatsPage(roomUid),
                  ),
                  if (broadcastRunningStatus == BroadcastRunningStatus.RUNNING)
                    IconButton(
                      onPressed: () => broadcastService.pauseBroadcast(roomUid),
                      icon: Icon(
                        Icons.pause_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (broadcastRunningStatus == BroadcastRunningStatus.PAUSE &&
                      waitingBroadcasts.isNotEmpty)
                    IconButton(
                      onPressed: () => broadcastService.resumeBroadcast(
                        roomUid,
                        waitingBroadcasts,
                      ),
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  if (broadcastRunningStatus == BroadcastRunningStatus.END)
                    IconButton(
                      onPressed: () => broadcastService.resendFailedBroadcasts(
                        roomUid,
                        failedBroadcasts.toList(),
                      ),
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  IconButton(
                    onPressed: () => broadcastService.cancelBroadcast(roomUid),
                    icon: Icon(
                      Icons.clear_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
