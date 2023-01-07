import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
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
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder(
      stream: callRepo.callingStatus,
      builder: (context, snapshot) {
        if (snapshot.data != CallStatus.NO_CALL) {
          return GestureDetector(
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
                ? Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withAlpha(100),
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
                              Icon(
                                callRepo.isVideo ? Icons.videocam : Icons.call,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              if (snapshot.data == CallStatus.CONNECTED)
                                StreamBuilder<CallTimer>(
                                  stream: callRepo.callTimer,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      var callHour =
                                          snapshot.data!.hours.toString();
                                      var callMin =
                                          snapshot.data!.minutes.toString();
                                      var callSecond =
                                          snapshot.data!.seconds.toString();
                                      callHour = callHour.length != 2
                                          ? '0$callHour'
                                          : callHour;
                                      callMin = callMin.length != 2
                                          ? '0$callMin'
                                          : callMin;
                                      callSecond = callSecond.length != 2
                                          ? '0$callSecond'
                                          : callSecond;
                                      return Text(
                                        '$callHour:$callMin:$callSecond',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
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
          return const SizedBox.shrink();
        }
      },
    );
  }
}
