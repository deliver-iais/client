import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ResumeAndPauseBroadcastIcons extends StatelessWidget {
  final Uid broadcastRoomId;
  final Color? iconsColor;
  final double? iconsSize;
  final List<BroadcastStatus> waitingBroadcastList;
  final List<BroadcastStatus> failedBroadcastList;
  final BroadcastRunningStatus broadcastRunningStatus;
  static final _broadcastService = GetIt.I.get<BroadcastService>();

  const ResumeAndPauseBroadcastIcons({
    Key? key,
    required this.broadcastRoomId,
    required this.broadcastRunningStatus,
    required this.waitingBroadcastList,
    required this.failedBroadcastList,
    this.iconsColor,
    this.iconsSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (broadcastRunningStatus == BroadcastRunningStatus.RUNNING)
          _buildBroadcastIcon(
            Icons.pause_rounded,
            () => _broadcastService.pauseBroadcast(broadcastRoomId),
            theme,
          ),
        if (broadcastRunningStatus == BroadcastRunningStatus.PAUSE &&
            waitingBroadcastList.isNotEmpty)
          _buildBroadcastIcon(
            Icons.play_arrow_rounded,
            () => _broadcastService.resumeBroadcast(
              broadcastRoomId,
              waitingBroadcastList.toList(),
            ),
            theme,
          ),
        if (broadcastRunningStatus == BroadcastRunningStatus.END)
          _buildBroadcastIcon(
            Icons.refresh_rounded,
            () => _broadcastService.resendFailedBroadcasts(
              broadcastRoomId,
              failedBroadcastList.toList(),
            ),
            theme,
          ),
        _buildBroadcastIcon(
          Icons.clear,
          () => _broadcastService.cancelBroadcast(broadcastRoomId),
          theme,
        )
      ],
    );
  }

  IconButton _buildBroadcastIcon(
    IconData icon,
    void Function() onPressed,
    ThemeData theme,
  ) =>
      IconButton(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconsSize,
          color: iconsColor ?? theme.colorScheme.tertiary,
        ),
      );
}
