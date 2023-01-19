import 'package:animations/animations.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'call_status.dart';

class HasCallRow extends StatefulWidget {
  const HasCallRow({super.key});

  @override
  HasCallRowState createState() => HasCallRowState();
}

class HasCallRowState extends State<HasCallRow> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<CallStatus>(
      stream: callRepo.callingStatus,
      builder: (context, snapshot) {
        Widget renderer;
        if (snapshot.data != CallStatus.NO_CALL) {
          renderer = GestureDetector(
            onTap: () {
              if (snapshot.data == CallStatus.CREATED && !callRepo.isCaller) {
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
                    duration: SUPER_ULTRA_SLOW_ANIMATION_DURATION,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          detectBackGroundColor(snapshot.data!),
                          detectBackGroundColor(snapshot.data!).withAlpha(100),
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                      style: theme.textTheme.subtitle2!
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
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        } else {
          renderer = const SizedBox.shrink();
        }
        return PageTransitionSwitcher(
          duration: SUPER_ULTRA_SLOW_ANIMATION_DURATION,
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
    );
  }

  Color detectBackGroundColor(CallStatus callStatus) {
    switch (callStatus) {
      case CallStatus.CONNECTED:
        return backgroundColorCard;

      case CallStatus.CONNECTING:
      case CallStatus.DISCONNECTED:
      case CallStatus.RECONNECTING:
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
