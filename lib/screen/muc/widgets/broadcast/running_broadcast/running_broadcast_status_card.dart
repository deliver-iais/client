import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/muc/widgets/broadcast/resume_and_pause_broadcast_icons.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/gradiant_circle_progress_bar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class RunningBroadcastStatusCard extends StatelessWidget {
  final Uid broadcastRoomId;
  final BehaviorSubject<List<BroadcastStatus>> allBroadcastStatus;
  static final _broadcastService = GetIt.I.get<BroadcastService>();
  static final _mucDao = GetIt.I.get<MucDao>();
  static final _i18n = GetIt.I.get<I18N>();

  const RunningBroadcastStatusCard({
    Key? key,
    required this.broadcastRoomId,
    required this.allBroadcastStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<BroadcastRunningStatus>(
      stream: _broadcastService.getBroadcastRunningStatus(broadcastRoomId),
      builder: (context, runningStatus) {
        return Container(
          margin: const EdgeInsetsDirectional.all(p8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _i18n.defaultTextDirection == TextDirection.ltr
                  ? [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.tertiaryContainer,
                    ]
                  : [
                      theme.colorScheme.tertiaryContainer,
                      theme.colorScheme.primaryContainer,
                    ],
            ),
            boxShadow: DEFAULT_BOX_SHADOWS,
            borderRadius: tertiaryBorder,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(p8),
            child: FutureBuilder<int>(
              future: _mucDao.getBroadCastAllMemberCount(broadcastRoomId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != 0) {
                  final allWeMemberCount = snapshot.data! - 1;
                  return _buildRunningBroadcastCard(
                    theme,
                    allWeMemberCount,
                    runningStatus.data,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        );
      },
    );
  }

  StreamBuilder<List<BroadcastStatus>> _buildRunningBroadcastCard(
    ThemeData theme,
    int allMemberCount,
    BroadcastRunningStatus? runningStatus,
  ) {
    return StreamBuilder<List<BroadcastStatus>>(
      stream: allBroadcastStatus,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final waitingBroadcasts = snapshot.data!
              .where(
                (element) =>
                    element.status == BroadcastMessageStatusType.WAITING,
              )
              .toList();
          final failedBroadcasts = snapshot.data!
              .where(
                (element) =>
                    element.status == BroadcastMessageStatusType.FAILED,
              )
              .toList();
          final waitingCount = waitingBroadcasts.length;
          final failedCount = failedBroadcasts.length;
          final broadcastRunningStatus =
              _broadcastService.getBroadcastRunningStatusDependOnWaitingCount(
            runningStatus,
            waitingCount,
          );
          return Row(
            children: [
              _buildBroadcastSuccessCountProgressBar(
                theme,
                1 - ((snapshot.data!.length) / allMemberCount),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(p8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBroadcastStatusDetails(
                      "${_i18n.get("failed")} : $failedCount",
                      theme,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildBroadcastStatusDetails(
                      "${_i18n.get("waiting")} : $waitingCount",
                      theme,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildBroadcastStatusDetails(
                      "${_i18n.get(
                        "status",
                      )} : ${_broadcastService.getBroadcastRunningStatusAsString(
                        broadcastRunningStatus,
                      )}",
                      theme,
                    )
                  ],
                ),
              ),
              const Spacer(),
              ResumeAndPauseBroadcastIcons(
                broadcastRoomId: broadcastRoomId,
                broadcastRunningStatus: broadcastRunningStatus,
                failedBroadcastList: failedBroadcasts,
                waitingBroadcastList: waitingBroadcasts,
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Text _buildBroadcastStatusDetails(String text, ThemeData themeData) => Text(
        text,
        style: TextStyle(
          color: themeData.colorScheme.primary,
        ),
      );

  Padding _buildBroadcastSuccessCountProgressBar(
    ThemeData theme,
    double progressValue,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(p4),
      child: SizedBox(
        width: 100,
        height: 100,
        child: TweenAnimationBuilder<double>(
          duration: AnimationSettings.standard,
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: progressValue,
            end: progressValue,
          ),
          builder: (context, value, _) => CustomPaint(
            size: const Size(100, 100),
            // no effect while adding child
            painter: GradiantCircleProgressBar(
              inactiveColor: theme.colorScheme.primary.withOpacity(0.1),
              progressValue: value,
              borderThickness: 10,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.inversePrimary,
              ],
            ),
            child: Center(
              child: Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
