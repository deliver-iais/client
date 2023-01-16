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
  final Uid roomUid;
  final void Function() hangUp;
  final bool isIncomingCall;

  const AudioCallScreen({
    super.key,
    required this.roomUid,
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
                  StreamBuilder<CallStatus>(
                    initialData: CallStatus.NO_CALL,
                    stream: _callRepo.callingStatus,
                    builder: (context, snapshot) {
                      return CallStatusWidget(
                        callStatus: snapshot.data!,
                        isIncomingCall: isIncomingCall,
                      );
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CenterAvatarInCall(
                    roomUid: roomUid,
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<CallStatus>(
            initialData: CallStatus.NO_CALL,
            stream: _callRepo.callingStatus,
            builder: (context, snapshot) {
              if (snapshot.data! != CallStatus.ENDED) {
                return CallBottomRow(
                  hangUp: hangUp,
                  isIncomingCall: isIncomingCall,
                  callStatus: snapshot.data!,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          if (_callRepo.isConnected) const HoleAnimation(),
        ],
      ),
    );
  }
}
