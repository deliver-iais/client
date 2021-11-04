import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

class CallBottomRow extends StatefulWidget {
  final localRenderer;
  RTCVideoRenderer remoteRenderer;

  CallBottomRow({Key key, this.localRenderer, this.remoteRenderer})
      : super(key: key);

  @override
  _CallBottomRowState createState() => _CallBottomRowState();
}

class _CallBottomRowState extends State<CallBottomRow> {
  Color _switchCameraIcon = Colors.black45;
  Color _offVideoCamIcon = Colors.black45;
  Color _muteMicIcon = Colors.black45;
  final _routingService = GetIt.I.get<RoutingService>();
  final callRepo = GetIt.I.get<CallRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  int index_switch_camera = 0;
  int index_speaker = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: _switchCameraIcon,
                child: const Icon(Icons.switch_camera),
                onPressed: _switchCamera,
              ),
              FloatingActionButton(
                backgroundColor: _offVideoCamIcon,
                child: const Icon(Icons.videocam_off_sharp),
                onPressed: _offVideoCam,
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

  _hangUp() async {
    _audioService.stopPlayBeepSound();
    _routingService.pop();
    await callRepo.endCall();
    await widget.localRenderer.dispose();
    await widget.remoteRenderer.dispose();
  }

  _switchCamera() {
    callRepo.switchCamera();
    index_switch_camera++;
    _switchCameraIcon =
        index_switch_camera.isOdd ? Colors.grey : Colors.black45;
    setState(() {});
  }

  _muteMic() {
    _muteMicIcon = callRepo.muteMicrophone() ? Colors.grey : Colors.black45;
    setState(() {});
  }

  _offVideoCam() {
    _offVideoCamIcon = callRepo.muteCamera() ? Colors.grey : Colors.black45;
    setState(() {});
  }
}
