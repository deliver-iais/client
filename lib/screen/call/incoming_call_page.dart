import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/in_video_call_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class InComingCallPage extends StatefulWidget {
  final Uid roomuid;

  InComingCallPage({Key key, this.roomuid}) : super(key: key);

  @override
  _InComingCallPageState createState() => _InComingCallPageState();
}

class _InComingCallPageState extends State<InComingCallPage> {
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  final _logger = GetIt.I.get<Logger>();

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  @override
  void initState() {
    _initRenderer();
    addStream();
    super.initState();
  }

  @override
  void dispose(){
    _disposeRenderer();
    super.dispose();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _disposeRenderer() async {
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
  }

  void acceptCall(Uid roomId) async {
    await callRepo.acceptCall(roomId);
  }

  addStream() async {
    callRepo?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    callRepo?.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    callRepo?.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });
    await callRepo?.initCall(true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //after 43 second all 51
    return StreamBuilder(
        stream: callRepo.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            if (snapshot.data == CallStatus.CREATED) {
              _logger.i("incoming call page open ");
              return Scaffold(
                  body: Stack(children: [
                RTCVideoView(
                  _localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.15),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          CircleAvatarWidget(widget.roomuid, 60),
                          FutureBuilder(
                              future: _roomRepo.getName(widget.roomuid),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      snapshot.data,
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                } else
                                  return Text("");
                              }),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Deliver Call",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ),
                        ],
                      )),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 50),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    callRepo.declineCall();
                                    _routingService.pop();
                                  },
                                  child: Icon(
                                    Icons.call_end,
                                    color: Colors.red,
                                  ),
                                  backgroundColor: Colors.black45,
                                ),
                              ),
                              FutureBuilder(
                                  future: _roomRepo.getIdByUid(widget.roomuid),
                                  builder: (context, snapshot) {
                                    return GestureDetector(
                                      child: Container(
                                        child: Lottie.asset(
                                            'assets/animations/accept_call.json',
                                            height: 300,
                                            width: 300),
                                        color: Colors.transparent,
                                        width: 100,
                                        height: 100,
                                      ),
                                      onTap: () {
                                        //we got error here
                                        acceptCall(widget.roomuid);
                                      },
                                    );
                                  }),
                            ]))),
              ]));
            } else if (snapshot.data == CallStatus.ACCEPTED ||
                snapshot.data == CallStatus.IN_CALL) {
              return InVideoCallPage(
                localRenderer: _localRenderer,
                remoteRenderer: _remoteRenderer,
                roomUid: widget.roomuid,
              );
            } else if (snapshot.data == CallStatus.ENDED) {
              _logger.i("we got end");
              _routingService.pop();
              _localRenderer.dispose();
              _remoteRenderer.dispose();
              return SizedBox.shrink();
            } else {
              _logger.i("we got else ${snapshot.data}");
              return SizedBox.shrink();
            }
          } else {
            _logger.i("we got null");
            return SizedBox.shrink();
          }
        });
  }
}
