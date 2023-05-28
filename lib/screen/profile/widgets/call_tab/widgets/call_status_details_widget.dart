import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallStatusDetailsWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
  static final _callService = GetIt.I.get<CallService>();

  final CallInfo callInfo;
  final DateTime time;
  final bool isIncomingCall;
  final Uid caller;

  const CallStatusDetailsWidget({
    super.key,
    required this.time,
    required this.isIncomingCall,
    required this.caller,
    required this.callInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callEventId = callInfo.callEvent.id;
    final callDuration = callEventId == ""
        ? callInfo.callEventOld.callDuration.toInt()
        : callInfo.callEvent.hasEnd()
            ? callInfo.callEvent.end.callDuration.toInt()
            : 0;
    final callId =
        callEventId == "" ? callInfo.callEventOld.callId : callEventId;

    final isVideo = callEventId == ""
        ? (callInfo.callEventOld.callType == CallEvent_CallType.VIDEO)
        : callInfo.callEvent.isVideo;
    return Container(
      padding: const EdgeInsetsDirectional.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isVideo
                        ? CupertinoIcons.video_camera
                        : CupertinoIcons.phone,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  CallState(
                    textStyle: theme.textTheme.titleMedium,
                    callEvent: callInfo.callEventOld,
                    callEventV2: callInfo.callEvent,
                    isIncomingCall: isIncomingCall,
                  ),
                ],
              ),
              if (callDuration != 0)
                DefaultTextStyle(
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.primary.withAlpha(130),
                  ),
                  child: CallTime(
                    time: DateTime.fromMillisecondsSinceEpoch(
                      callDuration,
                      isUtc: true,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isIncomingCall ? Icons.call_made : Icons.call_received,
                    color: callDuration == 0 ? Colors.red : Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateTimeFromNowFormat(time),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.primary.withAlpha(130),
                    ),
                    textDirection: _i18n.defaultTextDirection,
                  )
                ],
              ),
              if (callDuration != 0)
                FutureBuilder<String>(
                  future: _callService.getCallDataUsage(callId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data != "0.00 ${_i18n.get("kilo_byte")}") {
                      return Text(
                        snapshot.data!,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.primary.withAlpha(130),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
