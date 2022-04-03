import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HasCallRow extends StatefulWidget {
  const HasCallRow({Key? key}) : super(key: key);

  @override
  _HasCallRowState createState() => _HasCallRowState();
}

class _HasCallRowState extends State<HasCallRow> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.data != CallStatus.NO_CALL) {
            return GestureDetector(
                onTap: () {
                  if (snapshot.data == CallStatus.CREATED &&
                      !callRepo.isCaller) {
                    _routingService.openCallScreen(callRepo.roomUid!,
                        isIncomingCall: true,
                        isVideoCall: callRepo.isVideo);
                  } else {
                    _routingService.openCallScreen(callRepo.roomUid!,
                        isCallInitialized: true,
                        isVideoCall: callRepo.isVideo);
                  }
                },
                child: callRepo.roomUid != null
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withAlpha(100),
                          ],
                        )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FutureBuilder<String>(
                                  future: _roomRepo.getName(callRepo.roomUid!),
                                  builder: (context, name) {
                                    if (name.hasData) {
                                      return Text(
                                        name.data!,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                              Row(
                                children: [
                                  Icon(
                                      callRepo.isVideo
                                          ? Icons.videocam
                                          : Icons.call,
                                      color: Colors.white),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  if (snapshot.data == CallStatus.CONNECTED)
                                    StreamBuilder<CallTimer>(
                                        stream: callRepo.callTimer,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Text(
                                              snapshot.data!.hours.toString() +
                                                  ":" +
                                                  snapshot.data!.minutes
                                                      .toString() +
                                                  ":" +
                                                  snapshot.data!.seconds
                                                      .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white54),
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                      )
                    : const SizedBox.shrink());
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
