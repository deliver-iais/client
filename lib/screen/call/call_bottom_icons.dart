import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

import '../../shared/methods/platform.dart';

class CallBottomRow extends StatefulWidget {
  final void Function() hangUp;
  final bool isIncomingCall;

  const CallBottomRow({
    super.key,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  CallBottomRowState createState() => CallBottomRowState();
}

class CallBottomRowState extends State<CallBottomRow> {
  final _i18n = GetIt.I.get<I18N>();

  Color? _switchCameraIcon;

  Color? _offVideoCamIcon;

  Color? _speakerIcon;

  Color? _screenShareIcon;
  Color? _muteMicIcon;
  final callRepo = GetIt.I.get<CallRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _speakerIcon = callRepo.isSpeaker ? Colors.green : theme.shadowColor;
    _muteMicIcon = callRepo.isMicMuted ? Colors.green : theme.shadowColor;
    _offVideoCamIcon = callRepo.mute_camera.value
        ? theme.buttonTheme.colorScheme!.primary
        : theme.shadowColor.withOpacity(0.4);
    // _switchCameraIcon = callRepo.switching.value
    //     ? theme.buttonTheme.colorScheme!.primary
    //     : null;
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
                  onPressed: () => _declineCall(),
                  backgroundColor: theme.buttonTheme.colorScheme!.primary,
                  child: const Icon(
                    CupertinoIcons.phone_down_fill,
                    size: 40,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return callRepo.isVideo
          ? Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (isAndroid)
                      FloatingActionButton(
                        heroTag: 22,
                        backgroundColor: _switchCameraIcon,
                        child: const Icon(Icons.switch_camera_rounded),
                        onPressed: () => _switchCamera(theme),
                      )
                    else
                      const SizedBox.shrink(),
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
                    // TODO(AmirHossein): enable it after fixing 3 issues in flutter-webRtc project itself, https://gitlab.iais.co/deliver/wiki/-/issues/425
                    FloatingActionButton(
                      heroTag: 55,
                      backgroundColor: _screenShareIcon,
                      child: (isAndroid)
                          ? const Icon(Icons.mobile_screen_share)
                          : const Icon(Icons.screen_share_outlined),
                      onPressed: () => _shareScreen(theme),
                    ),
                    FloatingActionButton(
                      heroTag: 66,
                      onPressed: () => widget.hangUp(),
                      tooltip: 'Hangup',
                      backgroundColor: theme.buttonTheme.colorScheme!.primary,
                      child: const Icon(Icons.call_end),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 80, right: 50, left: 50),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: isWindows
                      ? MediaQuery.of(context).size.width / 2
                      : 9 * MediaQuery.of(context).size.width / 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35.0),
                    color: theme.cardColor.withOpacity(0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: isAndroid ? 75 : 80,
                          height: isAndroid ? 75 : 80,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: FittedBox(
                                  child: FloatingActionButton(
                                    heroTag: "1",
                                    elevation: 0,
                                    shape: const CircleBorder(),
                                    backgroundColor:
                                        theme.cardColor.withOpacity(0),
                                    hoverColor:
                                        theme.primaryColor.withOpacity(0.6),
                                    onPressed: () => _enableSpeaker(theme),
                                    child: Icon(
                                      CupertinoIcons.speaker_2,
                                      size: isAndroid ? 30 : 40,
                                      color: _speakerIcon,
                                    ),
                                  ),
                                ),
                              ),
                              Text(_i18n.get("speaker"),
                                  style: theme.textTheme.titleSmall),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: isAndroid ? 80 : 100,
                        width: isAndroid ? 80 : 100,
                        child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          heroTag: "2",
                          elevation: 0,
                          shape: const CircleBorder(),
                          child: Icon(
                            CupertinoIcons.phone_down_fill,
                            size: isAndroid ? 40 : 50,
                            color: Colors.white,
                          ),
                          onPressed: () => widget.hangUp(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: isAndroid ? 75 : 80,
                          height: isAndroid ? 75 : 80,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: FittedBox(
                                  child: FloatingActionButton(
                                    heroTag: "3",
                                    elevation: 0,
                                    shape: const CircleBorder(),
                                    backgroundColor:
                                        theme.cardColor.withOpacity(0),
                                    hoverColor:
                                        theme.primaryColor.withOpacity(0.6),
                                    onPressed: () => _muteMic(theme),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Icon(
                                        CupertinoIcons.mic_off,
                                        size: isAndroid ? 30 : 40,
                                        color: _muteMicIcon,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(_i18n.get("mute_call"),
                                  style: theme.textTheme.titleSmall),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
    }
  }

  Future<void> _switchCamera(ThemeData theme) async {
    _switchCameraIcon = !await callRepo.switchCamera()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  void _muteMic(ThemeData theme) {
    _muteMicIcon = callRepo.muteMicrophone()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  void _offVideoCam(ThemeData theme) {
    _offVideoCamIcon =
        callRepo.muteCamera() ? theme.buttonTheme.colorScheme!.primary : null;
    setState(() {});
  }

  void _shareScreen(ThemeData theme) {
    callRepo.shareScreen();
    _screenShareIcon =
        callRepo.isSharing ? theme.buttonTheme.colorScheme!.primary : null;
    setState(() {});
  }

  void _enableSpeaker(ThemeData theme) {
    _speakerIcon = callRepo.enableSpeakerVoice()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  void _acceptCall() {
    callRepo.acceptCall(callRepo.roomUid!);
  }

  void _declineCall() {
    callRepo.declineCall();
  }
}
