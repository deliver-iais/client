import 'package:deliver/repository/callRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallState extends StatelessWidget {
  final CallEvent_CallStatus callStatus;
  final int time;
  final bool isCurrentUser;
  final callRepo = GetIt.I.get<CallRepo>();

   CallState(
      {Key? key,
      required this.callStatus,
      required this.time,
      required this.isCurrentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (callStatus == CallEvent_CallStatus.ENDED &&
        isCurrentUser &&
        time == 0) {
      return const Text("canceled call");
    } else if (callStatus == CallEvent_CallStatus.DECLINED &&
        time == 0) {
      return const Text("call declined");
    } else if (callStatus == CallEvent_CallStatus.BUSY &&
        time == 0) {
      return const Text("Busy");
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        !callRepo. isCaller &&
        time == 0) {
      return const Text("missed call");
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        !callRepo. isCaller &&
        time != 0) {
      return const Text("Incoming call");
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        callRepo. isCaller &&
        time != 0) {
      return const Text("outgoing call");
    } else {
      return const SizedBox.shrink();
    }
  }
}
