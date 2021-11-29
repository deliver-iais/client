import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/widgets/msg_time.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class CallMessageWidget extends StatelessWidget {
  final Message message;
  final CallEvent _callEvent;
  final _autRepo = GetIt.I.get<AuthRepo>();

  CallMessageWidget({Key? key, required this.message})
      : _callEvent = message.json!.toCallEvent(),
        super(key: key);

  //todo :
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _autRepo.isCurrentUser(message.from)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
          width: 280,
          margin: const EdgeInsets.all(10),
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: _autRepo.isCurrentUser(message.from)
                ? ExtraTheme.of(context).sentMessageBox
                : ExtraTheme.of(context).receivedMessageBox,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _callEvent.newStatus.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(
                        _autRepo.isCurrentUser(message.from)
                            ? Icons.call_made
                            : Icons.call_received,
                        color: Colors.green,
                        size: 14,
                      ),
                      MsgTime(
                        time: DateTime.fromMillisecondsSinceEpoch(message.time),
                        isSent: false,
                      ),
                      Text(", 1 min 7 s",
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.1,
                              fontStyle: FontStyle.italic,
                              color: ExtraTheme.of(context)
                                  .textMessage
                                  .withAlpha(130))),
                    ],
                  ),
                ],
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.call,
                  color: Colors.cyan,
                  size: 35,
                ),
              ),
            ],
          )),
    );
  }
}
