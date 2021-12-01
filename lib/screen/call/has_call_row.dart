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
          if (snapshot.hasData && snapshot.data == CallStatus.CREATED) {
            return GestureDetector(
              onTap: () {
                if (snapshot.data == CallStatus.CREATED) {
                  _routingService.openInComingCallPage(
                      callRepo.roomUid!, false,context);
                }
                //Todo handel other
              },
              child: Container(
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
                                style: const TextStyle(color: Colors.white),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                      callRepo.isVideo
                          ? Icon(Icons.videocam, color: Colors.white)
                          : Icon(Icons.call, color: Colors.white)
                    ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: 30,
                color: Colors.greenAccent[400],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
