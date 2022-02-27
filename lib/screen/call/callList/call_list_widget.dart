import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';

class CallListWidget extends StatelessWidget {
  final CallEvent callEvent;

  const CallListWidget({Key? key, required this.callEvent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatarWidget(
              "2:2652b716-8dfc-4bf4-aca1-b8c911bbc342".asUid(), 23,
              isHeroEnabled: false, showSavedMessageLogoIfNeeded: true),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Roya Chitsaz",
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.call_made,
                      //Icons.call_received,
                      color: Colors.green,
                      size: 14,
                    ),
                    Text(
                      "  (2) January 1 at 4:07 PM",
                      style: TextStyle(
                        color:
                            ExtraTheme.of(context).textMessage.withAlpha(130),
                        fontSize: 12,
                        height: 1.2,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const IconButton(
            onPressed: null,
            icon: Icon(
              Icons.call,
              color: Colors.blueAccent,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
