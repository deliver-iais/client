import 'package:animations/animations.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HasCallRow extends StatefulWidget {
  const HasCallRow({super.key});

  @override
  HasCallRowState createState() => HasCallRowState();
}

class HasCallRowState extends State<HasCallRow> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _callService = GetIt.I.get<CallService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<CallStatus>(
      initialData: CallStatus.NO_CALL,
      stream: callRepo.callingStatus,
      builder: (context, snapshot) {
        if (callRepo.isCallFromNotActiveState) {
          return const SizedBox.shrink();
        }
        Widget renderer;
        if (snapshot.data != CallStatus.NO_CALL) {
          renderer = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (snapshot.data == CallStatus.IS_RINGING &&
                    !callRepo.isCaller) {
                  _routingService.openCallScreen(
                    callRepo.roomUid!,
                    isIncomingCall: true,
                    isVideoCall: callRepo.isVideo,
                  );
                } else {
                  _routingService.openCallScreen(
                    callRepo.roomUid!,
                    isCallInitialized: true,
                    isVideoCall: callRepo.isVideo,
                  );
                }
              },
              child: callRepo.roomUid != null
                  ? AnimatedContainer(
                      duration: AnimationSettings.superUltraSlow,
                      margin: const EdgeInsetsDirectional.only(bottom: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            detectBackGroundColor(snapshot.data!),
                            detectBackGroundColor(snapshot.data!)
                                .withAlpha(100),
                          ],
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: BAR_HEIGHT,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder<String>(
                              future: _roomRepo.getName(callRepo.roomUid!),
                              builder: (context, name) {
                                if (name.hasData) {
                                  return Flexible(
                                    child: TextLoader(
                                      text: Text(
                                        name.data!,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                      width: 120,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                CallStatusWidget(
                                  callStatus: snapshot.data!,
                                  isIncomingCall: !callRepo.isCaller,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        } else {
          renderer = const SizedBox.shrink();
        }
        return AnimatedContainer(
          curve: Curves.easeInOut,
          duration: AnimationSettings.standard,
          height: snapshot.data == CallStatus.NO_CALL ||
                  _callService.getUserCallState == UserCallState.NO_CALL
              ? 0
              : APPBAR_HEIGHT,
          child: PageTransitionSwitcher(
            duration: AnimationSettings.standard,
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
          ),
        );
      },
    );
  }

  Color detectBackGroundColor(CallStatus callStatus) {
    switch (callStatus) {
      case CallStatus.CONNECTED:
        return backgroundColorCard;

      case CallStatus.CONNECTING:
      case CallStatus.DISCONNECTED:
      case CallStatus.RECONNECTING:
      case CallStatus.WEAK_NETWORK:
        return Colors.orange;

      case CallStatus.FAILED:
      case CallStatus.NO_ANSWER:
      case CallStatus.ENDED:
      case CallStatus.BUSY:
      case CallStatus.DECLINED:
        return Colors.red;

      case CallStatus.ACCEPTED:
      case CallStatus.NO_CALL:
      case CallStatus.IS_RINGING:
      case CallStatus.CREATED:
        return Colors.blueAccent;
    }
  }
}
