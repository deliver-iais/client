import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class CallMessageWidget extends StatelessWidget {
  final Message message;
  final CallEvent_CallStatus _callEvent;
  final int _callDuration;
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();

  CallMessageWidget({Key? key, required this.message})
      : _callEvent = message.json!.toCallEvent().newStatus,
        _callDuration = message.json!.toCallDuration(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
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
                  isCurrentUser: _autRepo.isCurrentUser(message.from),
                ),
                const SizedBox(
                  height: 5,
                ),
                DefaultTextStyle(
                    style: TextStyle(
                      color: ExtraTheme.of(context).textMessage.withAlpha(130),
                      fontSize: 12,
                      height: 1.2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _autRepo.isCurrentUser(message.from)
                              ? Icons.call_made
                              : Icons.call_received,
                          color: Colors.green,
                          size: 14,
                        ),
                        MsgTime(
                          time:
                              DateTime.fromMillisecondsSinceEpoch(message.time),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        CallTime(
                          time: DateTime.fromMicrosecondsSinceEpoch(
                              _callDuration * 1000,
                              isUtc: true),
                        )
                      ],
                    )),
              ],
            ),
            InkWell(
              onTap: () {
                _routingService.openCallScreen(
                    message.roomUid.asUid(),
                    context: context);
              },
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.call,
                  color: Colors.cyan,
                  size: 35,
                ),
              ),
            ),
          ],
        ));
  }
}
