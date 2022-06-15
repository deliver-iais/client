import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallListWidget extends StatelessWidget {
  final CallInfo callEvent;
  final DateTime time;
  final bool isIncomingCall;
  final Uid caller;

  CallListWidget({
    Key? key,
    required this.time,
    required this.isIncomingCall,
    required this.caller,
    required this.callEvent,
  }) : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatarWidget(caller, 23, isHeroEnabled: false),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: _roomRepo.getName(caller),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Text(
                        snapshot.data!,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.subtitle1,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Row(
                  children: [
                    Icon(
                      callEvent.callEvent.callType == CallType.VIDEO
                          ? Icons.videocam_rounded
                          : Icons.call,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isIncomingCall ? Icons.call_made : Icons.call_received,
                      color: callEvent.callEvent.callDuration == 0
                          ? Colors.red
                          : Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateTimeFromNowFormat(time),
                      style: TextStyle(
                        color: theme.colorScheme.primary.withAlpha(130),
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          ExpandableIcon(),
        ],
      ),
    );
  }
}
