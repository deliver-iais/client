import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallState extends StatelessWidget {
  static final _messageExtractorServices =
      GetIt.I.get<MessageExtractorServices>();
  final CallEvent_CallStatus callStatus;
  final int time;
  final bool isIncomingCall;
  final TextStyle? textStyle;

  const CallState({
    super.key,
    required this.callStatus,
    required this.time,
    required this.isIncomingCall,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final text = _messageExtractorServices.getCallText(
      callStatus,
      time,
      isIncomingCall: isIncomingCall,
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
