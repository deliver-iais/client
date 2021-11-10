import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class CallMessageWidget extends StatelessWidget {
  final Message message;

  CallMessageWidget({Key key, this.message}) : super(key: key);
  CallEvent _callEvent;
  var _i18n = GetIt.I.get<I18N>();
  var _autRepo = GetIt.I.get<AuthRepo>();

  //todo :
  @override
  Widget build(BuildContext context) {
    _callEvent = message.json.toCallEvent();
    return _callEvent.newStatus != CallEvent_CallStatus.IS_RINGING
        ? Center(
            child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.only(
                    top: 5, left: 8.0, right: 8.0, bottom: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _i18n.get("call"),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Icon(
                      Icons.call,
                      color: Colors.blue,
                      size: 15,
                    ),
                    Icon(
                      _autRepo.isCurrentUser(message.from)
                          ? Icons.call_made
                          : Icons.call_received,
                      color: Colors.blue,
                      size: 15,
                    )
                  ],
                )),
          )
        : Container();
  }
}
