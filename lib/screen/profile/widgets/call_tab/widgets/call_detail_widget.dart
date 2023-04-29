import 'dart:math' as math;

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallDetails extends StatefulWidget {
  final CallInfo callEvent;
  final bool isIncomingCall;
  final Uid caller;

  const CallDetails({
    super.key,
    required this.isIncomingCall,
    required this.caller,
    required this.callEvent,
  });

  @override
  CallDetailsState createState() => CallDetailsState();
}

class CallDetailsState extends State<CallDetails> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.0),
          child: Divider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatarWidget(
              _authRepo.currentUserUid,
              24,
              isHeroEnabled: false,
            ),
            const SizedBox(width: 26),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(widget.isIncomingCall ? math.pi : 0),
              child: const Ws.asset("assets/animations/arrow.ws", height: 100),
            ),
            const SizedBox(width: 26),
            CircleAvatarWidget(widget.caller, 24, isHeroEnabled: false),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CallState(
                    textStyle: const TextStyle(fontSize: 17),
                    callStatus: widget.callEvent.callEventOld.callStatus,
                    time: widget.callEvent.callEventOld.callDuration.toInt(),
                    isIncomingCall: _authRepo
                        .isCurrentUser(widget.callEvent.from.toString()),
                  ),
                  if (widget.callEvent.callEventOld.callDuration != 0)
                    DefaultTextStyle(
                      style: TextStyle(
                        color: theme.colorScheme.primary.withAlpha(130),
                        fontSize: 14,
                      ),
                      child: CallTime(
                        time: DateTime.fromMillisecondsSinceEpoch(
                          widget.callEvent.callEventOld.callDuration.toInt(),
                          isUtc: true,
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        _routingService.openRoom(widget.caller.asString()),
                    icon: const Icon(CupertinoIcons.chat_bubble),
                  ),
                  IconButton(
                    onPressed: () =>
                        _routingService.openCallScreen(widget.caller),
                    icon: const Icon(CupertinoIcons.phone),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
