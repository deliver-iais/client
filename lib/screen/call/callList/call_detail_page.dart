import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_status.dart';
import 'package:deliver/screen/room/messageWidgets/call_message/call_time.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class CallDetailPage extends StatefulWidget {
  final CallInfo callEvent;
  final bool isIncomingCall;
  final Uid caller;
  final String monthName;

  const CallDetailPage(
      {Key? key,
      required this.isIncomingCall,
      required this.caller,
      required this.monthName,
      required this.callEvent})
      : super(key: key);

  @override
  _CallDetailPageState createState() => _CallDetailPageState();
}

class _CallDetailPageState extends State<CallDetailPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatarWidget(
                widget.isIncomingCall
                    ? widget.caller
                    : _authRepo.currentUserUid,
                23,
                isHeroEnabled: false,
                showSavedMessageLogoIfNeeded: false),
            Lottie.asset("assets/animations/arrow.json", height: 100),
            CircleAvatarWidget(
                widget.isIncomingCall
                    ? _authRepo.currentUserUid
                    : widget.caller,
                23,
                isHeroEnabled: false,
                showSavedMessageLogoIfNeeded: false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CallState(
                        textStyle: const TextStyle(fontSize: 17),
                        callStatus: findCallEventStatus(
                            widget.callEvent.callEvent.newStatus),
                        time: widget.callEvent.callEvent.callDuration,
                        isCurrentUser:
                            _authRepo.isCurrentUser(widget.callEvent.from)),
                    if (widget.callEvent.callEvent.callDuration != 0)
                      DefaultTextStyle(
                        style: TextStyle(
                          color: ExtraTheme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(130),
                          fontSize: 14,
                        ),
                        child: CallTime(
                            time: DateTime.fromMillisecondsSinceEpoch(
                                widget.callEvent.callEvent.callDuration,
                                isUtc: true)),
                      ),
                  ],
                )),
            Row(
              children: [
                IconButton(
                    onPressed: () =>
                        _routingService.openRoom(widget.caller.asString()),
                    icon: const Icon(Icons.message)),
                IconButton(
                    onPressed: () => _routingService
                        .openCallScreen(widget.caller, context: context),
                    icon: const Icon(Icons.call)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  CallEvent_CallStatus findCallEventStatus(CallStatus eventCallStatus) {
    switch (eventCallStatus) {
      case CallStatus.CREATED:
        return CallEvent_CallStatus.CREATED;
      case CallStatus.BUSY:
        return CallEvent_CallStatus.BUSY;
      case CallStatus.DECLINED:
        return CallEvent_CallStatus.DECLINED;
      case CallStatus.ENDED:
        return CallEvent_CallStatus.ENDED;
      case CallStatus.INVITE:
        return CallEvent_CallStatus.INVITE;
      case CallStatus.IS_RINGING:
        return CallEvent_CallStatus.IS_RINGING;
      case CallStatus.JOINED:
        return CallEvent_CallStatus.JOINED;
      case CallStatus.KICK:
        return CallEvent_CallStatus.KICK;
      case CallStatus.LEFT:
        return CallEvent_CallStatus.LEFT;
    }
  }
}
