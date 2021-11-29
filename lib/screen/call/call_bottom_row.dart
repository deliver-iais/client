import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

class CallBottomRow extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const CallBottomRow(
      {Key? key, required this.localRenderer, required this.remoteRenderer})
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
  int indexSwitchCamera = 0;
  int indexSpeaker = 0;

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
                backgroundColor: _muteMicIcon,
                child: (isAndroid())
                    ? const Icon(Icons.mobile_screen_share)
                    : const Icon(Icons.screen_share_outlined),
                onPressed: _shareScreen,
              ),
              FloatingActionButton(
                onPressed: _hangUp,
                tooltip: 'Hangup',
                child: const Icon(Icons.call_end),
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
    indexSwitchCamera++;
    _switchCameraIcon = indexSwitchCamera.isOdd ? Colors.grey : Colors.black45;
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

  _shareScreen() {
    callRepo.shareScreen();
  }
}
