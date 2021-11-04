import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HasCallRow extends StatefulWidget {
  const HasCallRow({Key key}) : super(key: key);

  @override
  _HasCallRowState createState() => _HasCallRowState();
}

class _HasCallRowState extends State<HasCallRow> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _audioService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null && snapshot.data == CallStatus.CREATED) {
            return GestureDetector(
              onTap: () {
                if (snapshot.data == CallStatus.CREATED &&
                    callRepo.roomUid != null)
                  _routingService.openInComingCallPage(callRepo.roomUid);
                //Todo handel other
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<Object>(
                          future: _roomRepo.getName(callRepo.roomUid),
                          builder: (context, name) {
                            if (name.hasData && name != null)
                              return Text(
                                name.data,
                                style: TextStyle(color: Colors.white),
                              );
                            else
                              return SizedBox.shrink();
                          }),
                      Icon(Icons.videocam, color: Colors.white),
                    ],
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: 30,
                color: Colors.greenAccent[400],
              ),
            );
          } else {
            //_audioService.stopPlayBeepSound();
            return SizedBox.shrink();
          }
        });
  }
}
