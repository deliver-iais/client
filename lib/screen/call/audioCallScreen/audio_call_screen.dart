import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/screen/call/center_avatar_image_in_call.dart';
import 'package:deliver/shared/widgets/animated_gradient.dart';

import 'package:deliver/shared/widgets/hole_animation.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioCallScreen extends StatelessWidget {
  static final _callRepo = GetIt.I.get<CallRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final Uid roomUid;
  final CallStatus callStatus;
  final String callStatusOnScreen;
  final void Function() hangUp;
  final bool isIncomingCall;

  const AudioCallScreen({
    super.key,
    required this.roomUid,
    required this.callStatus,
    required this.callStatusOnScreen,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedGradient(isConnected: _callRepo.isConnected),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.10,
              ),
              child: Column(
                children: [
                  CallStatusWidget(
                    callStatus: callStatus,
                    callStatusOnScreen: callStatusOnScreen,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CenterAvatarInCall(
                    roomUid: roomUid,
                  ),
                  StreamBuilder<bool>(
                    stream: _callRepo.incomingCallOnHold,
                    builder: (context, isCallOnHold) {
                      if (isCallOnHold.data ?? false) {
                        return Text(_i18n.get("call_on_hold"));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          if (callStatus != CallStatus.ENDED)
            CallBottomRow(
              hangUp: hangUp,
              isIncomingCall: isIncomingCall,
            ),
          if (_callRepo.isConnected) const HoleAnimation(),
        ],
      ),
    );
  }
}
