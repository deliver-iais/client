
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/video_call_service.dart';
import 'package:deliver/shared/methods/platform.dart';
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
  final _videoCallService = GetIt.I.get<VideoCallService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  final _logger = GetIt.I.get<Logger>();

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  @override
  void initState() {
    _audioService.stopPlayBeepSound();
    _initRenderer();
    addStream();
    super.initState();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void acceptCall(Uid roomId) async {
    await _videoCallService.acceptCall(roomId);
  }

  addStream() async {
    _videoCallService?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _videoCallService?.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    _videoCallService?.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });
    await _videoCallService?.initCall(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //after 43 second all 51
    return StreamBuilder(
        stream: _videoCallService.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null) {
            if(snapshot.data == "incomingCall"){
              _logger.i("we got incomming call");
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
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
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
                                  _videoCallService.declineCall();
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
                                      _routingService.openInVideoCallPage(
                                          _localRenderer, _remoteRenderer);
                                    },
                                  );
                                }),
                          ]))),
            ]));}
            else if(snapshot.data == "end"){
              _logger.i("we got end");
              _routingService.pop();
              return SizedBox.shrink();}
            else{
              _logger.i("we got els ${snapshot.data}");
              return SizedBox.shrink();}
          }
          else {
            _logger.i("we got null");
            return SizedBox.shrink();
          }
        });
  }
}
