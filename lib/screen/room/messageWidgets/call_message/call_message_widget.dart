import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallMessageWidget extends StatelessWidget {
  final Message message;
  final CustomColorScheme colorScheme;
  final bool isCallLog;

  final CallEvent? _callEvent;
  final CallLog? _callLog;
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _callRepo = GetIt.I.get<CallRepo>();
  static final _callService = GetIt.I.get<CallService>();

  CallMessageWidget({
    super.key,
    required this.message,
    required this.colorScheme,
    this.isCallLog = false,
  })  : _callEvent = isCallLog ? null : message.json.toCallEvent(),
        _callLog = isCallLog ? message.json.toCallLog() : null;

  @override
  Widget build(BuildContext context) {
    final int callDuration;
    final bool isVideo;
    final bool isIncomingCall;
    if (_callEvent != null) {
      callDuration = _callLog!.end.callDuration.toInt();
      isVideo = _callEvent!.callType == CallEvent_CallType.VIDEO;
      isIncomingCall = _callLog!.end.isCaller;
    } else {
      if (_callLog!.hasEnd()) {
        callDuration = _callLog!.end.callDuration.toInt();
      } else {
        callDuration = 0;
      }
      isVideo = _callLog!.isVideo;
      isIncomingCall = _callLog!.end.isCaller;

    }
    return Container(
      width: 210,
      margin: const EdgeInsetsDirectional.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CallState(
                callEvent: _callEvent,
                callLog: _callLog,
                isIncomingCall: _authRepo.isCurrentUser(message.from),
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
                      color: callDuration != 0 ? Colors.green : Colors.red,
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
                        callDuration * 1000,
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
                ? () => _callRepo.openCallScreen(
                      message.roomUid,
                      isVideoCall: isVideo,
                    )
                : null,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                isVideo ? CupertinoIcons.video_camera : CupertinoIcons.phone,
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
