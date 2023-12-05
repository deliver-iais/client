import 'package:animations/animations.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/screen/call/center_avatar_image_in_call.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AudioCallScreen extends StatelessWidget {
  final bool isIncomingCall;

  final BehaviorSubject<bool> showButtonRow = BehaviorSubject.seeded(true);

  AudioCallScreen({
    super.key,
    this.isIncomingCall = false,
  });

  final _callRepo = GetIt.I.get<CallRepo>();
  final _callService = GetIt.I.get<CallService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showButtonRow.add(!showButtonRow.value),
        child: Stack(
          children: [
            Background(),
            Center(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  top: MediaQuery.of(context).size.height * 0.1,
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
                    if (_callRepo.roomUid != null)
                      CenterAvatarInCall(
                        roomUid: _callRepo.roomUid!,
                        isVideo: false,
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
                if (_callRepo.roomUid != null &&
                    (!_callService.isHiddenCallBottomRow(
                            _callRepo.callingStatus.value) ||
                        showButtonRow.value)) {
                  renderer = CallBottomRow(
                    isIncomingCall: isIncomingCall,
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
            // StreamBuilder<bool>(
            //   initialData: false,
            //   stream: _callRepo.isConnectedSubject,
            //   builder: (context, snapshot) {
            //     if (snapshot.data!) {
            //       return const HoleAnimation();
            //     } else {
            //       return const SizedBox.shrink();
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
