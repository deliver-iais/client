import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallState extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final CallEvent_CallStatus callStatus;
  final int time;
  final bool isCurrentUser;
  final TextStyle? textStyle;

  CallState({
    Key? key,
    required this.callStatus,
    required this.time,
    required this.isCurrentUser,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = getCallText(
      _i18n,
      callStatus,
      time,
      fromCurrentUser: isCurrentUser,
    );

    if (text != null) {
      return Text(
        text,
        style: textStyle,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
