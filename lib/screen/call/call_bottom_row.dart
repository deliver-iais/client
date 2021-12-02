import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallBottomRow extends StatefulWidget {
  final Function hangUp;

  const CallBottomRow({Key? key, required this.hangUp}) : super(key: key);

  @override
  _CallBottomRowState createState() => _CallBottomRowState();
}

class _CallBottomRowState extends State<CallBottomRow> {
  Color _switchCameraIcon = Colors.black45;
  Color _offVideoCamIcon = Colors.black45;
  Color _speakerIcon = Colors.black45;
  Color _screenShareIcon = Colors.black45;
  Color _muteMicIcon = Colors.black45;
  final callRepo = GetIt.I.get<CallRepo>();
  int indexSwitchCamera = 0;
  int screenShareIndex = 0;
  int SpeakerIndex = 0;

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
                backgroundColor: _screenShareIcon,
                child: (isAndroid())
                    ? const Icon(Icons.mobile_screen_share)
                    : const Icon(Icons.screen_share_outlined),
                onPressed: _shareScreen,
              ),
              FloatingActionButton(
                onPressed: () {
                  widget.hangUp();
                },
                tooltip: 'Hangup',
                child: const Icon(Icons.call_end),
                backgroundColor: Colors.red,
              ),
            ]),
      ),
    );
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
    screenShareIndex++;
    _screenShareIcon = screenShareIndex.isOdd ? Colors.grey : Colors.black45;
    setState(() {});
  }

}
