import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallMessageWidget extends StatelessWidget {
  final Message message;
  final CustomColorScheme colorScheme;
  final CallEvent_CallStatus _callEvent;
  final int _callDuration;
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _callService = GetIt.I.get<CallService>();
  final bool _isVideo;

  CallMessageWidget({
    super.key,
    required this.message,
    required this.colorScheme,
  })  : _callEvent = message.json.toCallEvent().callStatus,
        _callDuration = message.json.toCallEvent().callDuration.toInt(),
        _isVideo =
            message.json.toCallEvent().callType == CallEvent_CallType.VIDEO;

  @override
  Widget build(BuildContext context) {
    final isIncomingCall = (_callEvent == CallEvent_CallStatus.DECLINED ||
            _callEvent == CallEvent_CallStatus.BUSY)
        ? _authRepo.isCurrentUser(message.to)
        : _authRepo.isCurrentUser(message.from);
    return Container(
      width: 210,
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CallState(
                time: _callDuration,
                callStatus: _callEvent,
                isCurrentUser: _authRepo.isCurrentUser(message.from),
              ),
              const SizedBox(
                height: 5,
              ),
              DefaultTextStyle(
                style: TextStyle(
                  color: ExtraTheme.of(context)
                      .messageColorScheme(message.from)
                      .onPrimaryContainerLowlight(),
                  fontSize: 13,
                ),
                child: Row(
                  children: [
                    Icon(
                      isIncomingCall ? Icons.call_made : Icons.call_received,
                      color: _callDuration != 0 ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    MsgTime(
                      time: DateTime.fromMillisecondsSinceEpoch(message.time),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CallTime(
                      time: DateTime.fromMicrosecondsSinceEpoch(
                        _callDuration * 1000,
                        isUtc: true,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: (_callService.getUserCallState == UserCallState.NO_CALL)
                ? () => _routingService.openCallScreen(
                      message.roomUid.asUid(),
                      isVideoCall: _isVideo,
                    )
                : null,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                _isVideo ? CupertinoIcons.video_camera : CupertinoIcons.phone,
                color: colorScheme.primary,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
