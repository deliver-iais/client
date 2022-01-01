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

//TODO SHOW AUDIO CALL
class _HasCallRowState extends State<HasCallRow> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.data != CallStatus.ENDED ||
              snapshot.data != CallStatus.NO_CALL) {
            return GestureDetector(
                onTap: () {
                  if (callRepo.isVideo) {
                    //Todo handle this case
                  } else {
                    if (snapshot.data == CallStatus.CREATED &&
                        !callRepo.isCaller) {
                      _routingService.openCallScreen(callRepo.roomUid!,
                          isIncomingCall: true, context: context , isVideoCall:callRepo.isVideo);
                    } else {
                      _routingService.openCallScreen(callRepo.roomUid!,
                          isCallInitialized: true, context: context, isVideoCall:callRepo.isVideo);
                    }
                  }
                },
                child: callRepo.roomUid != null
                    ? Container(
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
                              callRepo.isVideo
                                  ? const Icon(Icons.videocam,
                                      color: Colors.white)
                                  : const Icon(Icons.call, color: Colors.white)
                            ],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 30,
                        color: Colors.greenAccent[400],
                      )
                    : const SizedBox.shrink());
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
