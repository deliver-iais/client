import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallState extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();
  final CallEventV2? callEventV2;
  final CallEvent? callEvent;
  final CallLog? callLog;
  final bool isIncomingCall;
  final TextStyle? textStyle;

  const CallState({
    super.key,
    this.callEvent,
    this.callEventV2,
    this.callLog,
    required this.isIncomingCall,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final String? text;
    if (callEvent != null && callEvent!.callId != "") {
      text = _messageExtractorServices.getCallText(
        callEvent!.callStatus,
        callEvent!.callDuration.toInt(),
        isIncomingCall: isIncomingCall,
      );
    } else if (callEventV2 != null && callEventV2!.id != "") {
      text = _messageExtractorServices.getCallTextFromCallEventV2(
        callEventV2!,
        callEventV2!.hasEnd() ? callEventV2!.end.callDuration.toInt() : 0,
        isIncomingCall: isIncomingCall,
      );
    } else if (callLog != null && callLog!.id != "") {
      text = _messageExtractorServices.getCallTextFromCallLog(
        callLog!,
        callLog!.hasEnd() ? callLog!.end.callDuration.toInt() : 0,
        isIncomingCall: isIncomingCall,
      );
    } else {
      return const SizedBox.shrink();
    }
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
