import 'package:deliver/repository/callRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class CallBottomRow extends StatefulWidget {
  final Function hangUp;
  final bool isIncomingCall;

  const CallBottomRow(
      {Key? key, required this.hangUp, this.isIncomingCall = false})
      : super(key: key);

  @override
  _CallBottomRowState createState() => _CallBottomRowState();
}

class _CallBottomRowState extends State<CallBottomRow> {
  Color? _switchCameraIcon;

  Color? _offVideoCamIcon;

  Color? _speakerIcon;

  // Color _screenShareIcon = Colors.black45;
  Color? _muteMicIcon;
  final callRepo = GetIt.I.get<CallRepo>();
  int indexSwitchCamera = 0;
  int screenShareIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _speakerIcon =
        callRepo.isSpeaker ? theme.buttonTheme.colorScheme!.primary : null;
    _muteMicIcon =
        callRepo.isMicMuted ? theme.buttonTheme.colorScheme!.primary : null;
    _offVideoCamIcon = callRepo.mute_camera.value
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    _switchCameraIcon = callRepo.switching.value
        ? theme.buttonTheme.colorScheme!.primary
        : null;

    if (widget.isIncomingCall) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      color: Colors.transparent,
                      child: FloatingActionButton(
                        heroTag: 11,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: Lottie.asset(
                          'assets/animations/accept_call.json',
                        ),
                        onPressed: () => _acceptCall(),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: FloatingActionButton(
                        child: const Icon(
                          Icons.call_end_rounded,
                          size: 40,
                        ),
                        onPressed: () => _declineCall(),
                        backgroundColor: theme.buttonTheme.colorScheme!.primary,
                      ),
                    )
                  ])));
    } else {
      return callRepo.isVideo
          ? Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 22,
                        backgroundColor: _switchCameraIcon,
                        child: const Icon(Icons.switch_camera_rounded),
                        onPressed: () => _switchCamera(theme),
                      ),
                      FloatingActionButton(
                        heroTag: 33,
                        backgroundColor: _offVideoCamIcon,
                        child: const Icon(Icons.videocam_off_rounded),
                        onPressed: () => _offVideoCam(theme),
                      ),
                      FloatingActionButton(
                        heroTag: 44,
                        backgroundColor: _muteMicIcon,
                        child: const Icon(Icons.mic_off_rounded),
                        onPressed: () => _muteMic(theme),
                      ),
                      //TODO after 3 issue fix on flutter-webRtc
                      // FloatingActionButton(
                      //   heroTag: 55,
                      //   backgroundColor: _screenShareIcon,
                      //   child: (isAndroid())
                      //       ? const Icon(Icons.mobile_screen_share)
                      //       : const Icon(Icons.screen_share_outlined),
                      //   onPressed: () => _shareScreen(),
                      // ),
                      FloatingActionButton(
                        heroTag: 66,
                        onPressed: () => widget.hangUp(),
                        tooltip: 'Hangup',
                        child: const Icon(Icons.call_end),
                        backgroundColor: theme.buttonTheme.colorScheme!.primary,
                      ),
                    ]),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 80, right: 50, left: 50),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                            width: 60,
                            height: 60,
                            child: FloatingActionButton(
                              heroTag: "1",
                              elevation: 0,
                              backgroundColor: _speakerIcon,
                              onPressed: () => _enableSpeaker(theme),
                              child: const Icon(
                                Icons.volume_up_rounded,
                                color: Colors.white70,
                                size: 35,
                              ),
                            )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          height: 110,
                          width: 110,
                          child: FloatingActionButton(
                            backgroundColor:
                                theme.buttonTheme.colorScheme!.primary,
                            heroTag: "2",
                            elevation: 0,
                            child: const Icon(
                              Icons.call_end_rounded,
                              size: 50,
                            ),
                            onPressed: () => widget.hangUp(),
                          ),
                        ),
                        SizedBox(
                            width: 60,
                            height: 60,
                            child: FloatingActionButton(
                              heroTag: "3",
                              elevation: 0,
                              backgroundColor: _muteMicIcon,
                              onPressed: () => _muteMic(theme),
                              child: const Icon(
                                Icons.mic_off,
                                size: 35,
                                color: Colors.white70,
                              ),
                            ))
                      ])));
    }
  }

  _switchCamera(ThemeData theme) {
    callRepo.switchCamera();
    indexSwitchCamera++;
    _switchCameraIcon =
        indexSwitchCamera.isOdd ? theme.buttonTheme.colorScheme!.primary : null;
    setState(() {});
  }

  _muteMic(ThemeData theme) {
    _muteMicIcon = callRepo.muteMicrophone()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  _offVideoCam(ThemeData theme) {
    _offVideoCamIcon =
        callRepo.muteCamera() ? theme.buttonTheme.colorScheme!.primary : null;
    setState(() {});
  }

  // _shareScreen() {
  //   callRepo.shareScreen();
  //   screenShareIndex++;
  //   _screenShareIcon = screenShareIndex.isOdd ? Colors.grey : Colors.black45;
  //   setState(() {});
  // }

  _enableSpeaker(ThemeData theme) {
    _speakerIcon = callRepo.enableSpeakerVoice()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  _acceptCall() {
    callRepo.acceptCall(callRepo.roomUid!);
  }

  _declineCall() {
    callRepo.declineCall();
  }
}
