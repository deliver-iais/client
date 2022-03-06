import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallListWidget extends StatelessWidget {
  final CallInfo callEvent;

  CallListWidget({Key? key, required this.callEvent}) : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatarWidget(callEvent.to.asUid(), 23,
              isHeroEnabled: false, showSavedMessageLogoIfNeeded: false),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                    future: _roomRepo.getName(callEvent.to.asUid()),
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
                    }),
                Row(
                  children: [
                    const Icon(
                      Icons.call_made,
                      //Icons.call_received,
                      color: Colors.green,
                      size: 14,
                    ),
                    Text(
                      callEvent.callEvent.callDuration.toString(),
                      style: TextStyle(
                        color: ExtraTheme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(130),
                        fontSize: 12,
                        height: 1.2,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: null,
            icon: Icon(
              callEvent.callEvent.callType == CallType.VIDEO
                  ? Icons.videocam_rounded
                  : Icons.call,
              color: Colors.blueAccent,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
