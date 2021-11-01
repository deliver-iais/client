import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/call_bottom_row.dart';
import 'package:deliver/screen/call/in_video_call_page.dart';
import 'package:deliver/screen/room/pages/roomPage.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/video_call_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class VideoCallPage extends StatefulWidget {
  final Room room;

  VideoCallPage({Key key, this.room}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final _videoCallService = GetIt.I.get<VideoCallService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  final _logger = GetIt.I.get<Logger>();

  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();

  @override
  void initState() {
    _initRenderer();
    startCall();
    _audioService.playBeepSound();
    super.initState();
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void startCall() async {
    _videoCallService?.onLocalStream = ((stream) {
      _localRenderer.srcObject = stream;
    });

    _videoCallService?.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
    });

    _videoCallService?.onRemoveRemoteStream = ((stream) {
      _remoteRenderer.srcObject = null;
    });

    await _videoCallService.startCall(widget.room.uid.asUid());

    setState(() {});
  }

  @override
  void dispose() {
    _logger.i("call dispose");
    //_audioService.stopBusySound();
    _audioService.stopPlayBeepSound();
    _videoCallService.endCall();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _videoCallService.callingStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot != null && snapshot.data == "busy")
            _audioService.playBusySound();
          if (snapshot.hasData && snapshot != null && snapshot.data == "answer"){
            _audioService.stopPlayBeepSound();
            return InVideoCallPage(
              remoteRenderer: _remoteRenderer,
              localRenderer: _localRenderer,
            );}
          else if (snapshot.hasData && snapshot != null)
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
                      child: Column(children: [
                        CircleAvatarWidget(widget.room.uid.asUid(), 60),
                        FutureBuilder(
                            future: _roomRepo.getName(widget.room.uid.asUid()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    snapshot.data,
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                );
                              } else
                                return Text("");
                            })
                      ]))),
              CallBottomRow(
                room: widget.room,
              ),
              if (snapshot.data == "declined")
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.45),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Declined",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
              else if (snapshot.data == "busy")
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.45),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "busy",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.45),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Ringing",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                )
            ]));
          else
            return RoomPage(
              key: ValueKey("/room/${widget.room.uid}"),
              roomId: widget.room.uid,
              forwardedMessages: [],
            );
        });
  }
}
