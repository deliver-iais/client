import 'package:audioplayers/audioplayers.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/videoCall_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

class CallBottomRow extends StatefulWidget {
  final localRenderer;
  final Room room;
  final AudioCache player;
  final bool isVideoCall;
  MediaStream localStream;

  CallBottomRow(
      {Key key,
      this.localRenderer,
      this.player,
      this.localStream,
      this.room,
      this.isVideoCall})
      : super(key: key);

  @override
  _CallBottomRowState createState() => _CallBottomRowState();
}

class _CallBottomRowState extends State<CallBottomRow> {
  Color _switchCameraIcon = Colors.black45;
  Color _offVideoCamIcon = Colors.black45;
  Color _muteMicIcon = Colors.black45;
  final _routingService = GetIt.I.get<RoutingService>();
  final _videoCallService = GetIt.I.get<VideoCallService>();
  int index_switch_camera = 0;
  int index_speaker = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50, right: 25, left: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              widget.isVideoCall
                  ? FloatingActionButton(
                      backgroundColor: _switchCameraIcon,
                      child: const Icon(Icons.switch_camera),
                      onPressed: _switchCamera,
                    )
                  : FloatingActionButton(
                      backgroundColor: _switchCameraIcon,
                      child: const Icon(Icons.volume_up),
                      onPressed: () {}),
              widget.isVideoCall
                  ? FloatingActionButton(
                      backgroundColor: _offVideoCamIcon,
                      child: const Icon(Icons.videocam_off_sharp),
                      onPressed: _offVideoCam,
                    )
                  : FloatingActionButton(
                      backgroundColor: _switchCameraIcon,
                      child: const Icon(Icons.videocam),
                      onPressed: null, //ToDo request for video call
                    ),
              FloatingActionButton(
                backgroundColor: _muteMicIcon,
                child: const Icon(Icons.mic_off),
                onPressed: _muteMic,
              ),
              FloatingActionButton(
                onPressed: _hangUp,
                tooltip: 'Hangup',
                child: Icon(Icons.call_end),
                backgroundColor: Colors.red,
              ),
            ]),
      ),
    );
  }

  _hangUp() {
    widget.player.fixedPlayer.stop();
    _routingService.pop();
    _videoCallService.endCall();

  }

  _switchCamera() {
    if (widget.localStream != null) {
      Helper.switchCamera(widget.localStream.getVideoTracks()[0]);
      index_switch_camera++;
      _switchCameraIcon =
          index_switch_camera.isOdd ? Colors.grey : Colors.black45;
      setState(() {});
    }
  }

  _muteMic() {
    _videoCallService.muteMicrophone();
  }

  _offVideoCam() {
    _videoCallService.muteCamera();
  }

  _onSpeaker() {
    widget.localStream.getAudioTracks()[0].enableSpeakerphone(true);
  }
}
