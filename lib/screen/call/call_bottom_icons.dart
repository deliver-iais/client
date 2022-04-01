import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/services/routing_service.dart';
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
  Color _switchCameraIcon = Colors.black45;
  Color _offVideoCamIcon = Colors.black45;
  Color _speakerIcon = Colors.black45;

  // Color _screenShareIcon = Colors.black45;
  Color _muteMicIcon = Colors.black45;
  final callRepo = GetIt.I.get<CallRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  int indexSwitchCamera = 0;
  int screenShareIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.call_end_rounded,
                          size: 40,
                        ),
                        onPressed: () => _declineCall(),
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
                        child: const Icon(Icons.switch_camera),
                        onPressed: () => _switchCamera(),
                      ),
                      FloatingActionButton(
                        heroTag: 33,
                        backgroundColor: _offVideoCamIcon,
                        child: const Icon(Icons.videocam_off_sharp),
                        onPressed: () => _offVideoCam(),
                      ),
                      FloatingActionButton(
                        heroTag: 44,
                        backgroundColor: _muteMicIcon,
                        child: const Icon(Icons.mic_off),
                        onPressed: () => _muteMic(),
                      ),
                      //TODO after 3 issue fix on flutter-webRtc
                      // FloatingActionButton(
                      //   heroTag: 55,
                      //   backgroundColor: _screenShareIcon,
                      //   child: (isAndroid)
                      //       ? const Icon(Icons.mobile_screen_share)
                      //       : const Icon(Icons.screen_share_outlined),
                      //   onPressed: () => _shareScreen(),
                      // ),
                      FloatingActionButton(
                        heroTag: 66,
                        onPressed: () => widget.hangUp(),
                        tooltip: 'Hangup',
                        child: const Icon(Icons.call_end),
                        backgroundColor: Colors.red,
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
                              onPressed: () => _enableSpeaker(),
                              child: const Icon(
                                Icons.volume_up,
                                color: Colors.white70,
                                size: 35,
                              ),
                            )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          height: 110,
                          width: 110,
                          child: FloatingActionButton(
                            backgroundColor: const Color(0xffcf6869),
                            heroTag: "2",
                            elevation: 0,
                            child: const Icon(
                              Icons.call_end,
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
                              onPressed: () => _muteMic(),
                              child: const Icon(
                                Icons.mic_off,
                                size: 35,
                                color: Colors.white70,
                              ),
                            ))
                      ])));
    }
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

  // _shareScreen() {
  //   callRepo.shareScreen();
  //   screenShareIndex++;
  //   _screenShareIcon = screenShareIndex.isOdd ? Colors.grey : Colors.black45;
  //   setState(() {});
  // }

  _enableSpeaker() {
    _speakerIcon = callRepo.enableSpeakerVoice() ? Colors.grey : Colors.black45;
    setState(() {});
  }

  _acceptCall() {
    callRepo.acceptCall(callRepo.roomUid!);
  }

  _declineCall() {
    callRepo.declineCall();
    _routingService.pop();
  }
}
