import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/video_call_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HasCallRow extends StatefulWidget {
  const HasCallRow({Key key}) : super(key: key);

  @override
  _HasCallRowState createState() => _HasCallRowState();
}

class _HasCallRowState extends State<HasCallRow> {
  final _videoCallService = GetIt.I.get<VideoCallService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _videoCallService.hasCall,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            return StreamBuilder(
                stream: _videoCallService.callingStatus,
                builder: (context, callingStatus) {
                  return GestureDetector(
                    onTap: () {
                      if (callingStatus.hasData &&
                          callingStatus != null &&
                          callingStatus.data == "incomingCall") {
                        _routingService.openInComingCallPage(snapshot.data);
                      }
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FutureBuilder<Object>(
                                future: _roomRepo.getName(snapshot.data),
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
                });
          } else
            return SizedBox.shrink();
        });
  }
}
