import 'package:animations/animations.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/screen/call/center_avatar_image_in_call.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/widgets/animated_gradient.dart';
import 'package:deliver/shared/widgets/hole_animation.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AudioCallScreen extends StatelessWidget {
  static final _callRepo = GetIt.I.get<CallRepo>();
  static final _callService = GetIt.I.get<CallService>();
  final Uid roomUid;
  final void Function() hangUp;
  final bool isIncomingCall;

  final BehaviorSubject<bool> showButtonRow = BehaviorSubject.seeded(true);

  AudioCallScreen({
    super.key,
    required this.roomUid,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showButtonRow.add(!showButtonRow.value),
        child: Stack(
          children: [
            AnimatedGradient(isConnected: _callRepo.isConnected),
            Center(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
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
            StreamBuilder<Object>(
              stream: MergeStream([
                _callRepo.callingStatus,
                showButtonRow,
              ]),
              builder: (context, snapshot) {
                Widget renderer;
                if (!_callService
                        .isHiddenCallBottomRow(_callRepo.callingStatus.value) ||
                    showButtonRow.value) {
                  renderer = CallBottomRow(
                    hangUp: hangUp,
                    isIncomingCall: isIncomingCall,
                    callStatus: _callRepo.callingStatus.value,
                  );
                } else {
                  renderer = const SizedBox.shrink();
                }
                return PageTransitionSwitcher(
                  duration: AnimationSettings.ultraSlow,
                  transitionBuilder: (
                    child,
                    animation,
                    secondaryAnimation,
                  ) {
                    return SharedAxisTransition(
                      fillColor: Colors.transparent,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.vertical,
                      child: child,
                    );
                  },
                  child: renderer,
                );
              },
            ),
            StreamBuilder<bool>(
              initialData: false,
              stream: _callRepo.isConnectedSubject,
              builder: (context, snapshot) {
                if (snapshot.data!) {
                  return const HoleAnimation();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
