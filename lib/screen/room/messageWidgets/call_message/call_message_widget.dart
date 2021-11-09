import 'package:deliver/box/message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';

class CallMessageWidget extends StatelessWidget{
  final Message message;

   CallMessageWidget({Key key, this.message}) : super(key: key);
  CallEvent _callEvent;

  //todo :
  @override
  Widget build(BuildContext context) {
    _callEvent = message.json.toCallEvent();
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.only(
            top: 5, left: 8.0, right: 8.0, bottom: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text("call",style: TextStyle(color: ExtraTheme.of(context).textField,fontSize: 20),),
      ),
    );
  }
}