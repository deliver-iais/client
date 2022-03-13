import 'package:deliver/repository/callRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallState extends StatelessWidget {
  final CallEvent_CallStatus callStatus;
  final int time;
  final bool isCurrentUser;
  final TextStyle? textStyle;
  final callRepo = GetIt.I.get<CallRepo>();

  CallState({Key? key,
    required this.callStatus,
    required this.time,
    required this.isCurrentUser, this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (callStatus == CallEvent_CallStatus.ENDED &&
        isCurrentUser &&
        time == 0) {
      return Text("canceled call", style: textStyle,);
    } else if (callStatus == CallEvent_CallStatus.DECLINED && time == 0) {
      return Text("call declined", style: textStyle,);
    } else if (callStatus == CallEvent_CallStatus.BUSY && time == 0) {
      return Text("Busy", style: textStyle,);
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        !callRepo.isCaller &&
        time == 0) {
      return Text("missed call", style: textStyle,);
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        isCurrentUser &&
        time != 0) {
      return Text("outgoing call", style: textStyle,);
    } else if (callStatus == CallEvent_CallStatus.ENDED && time != 0) {
      return Text("Incoming call", style: textStyle,);
    } else {
      return const SizedBox.shrink();
    }
  }
}
