import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/shareScreen/screen_select_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
  final boxSize = isAndroid ? 40.0 : 60.0;
  final iconSize = isAndroid ? 30.0 : 40.0;

  Color? _switchCameraColor;
  Color? _offVideoCamColor;
  Color? _speakerColor;
  Color? _screenShareColor;
  Color? _muteMicColor;

  IconData? _offVideoCamIcon;
  IconData? _speakerIcon;
  IconData? _screenShareIcon;
  IconData? _muteMicIcon;

  final callRepo = GetIt.I.get<CallRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _speakerColor = callRepo.isSpeaker ? Colors.green : theme.shadowColor;
    _muteMicColor = callRepo.isMicMuted ? Colors.green : theme.shadowColor;
    _offVideoCamColor =
        callRepo.mute_camera.value ? theme.shadowColor : Colors.green;
    _switchCameraColor =
        callRepo.switching.value ? Colors.green : theme.shadowColor;
    _screenShareColor = callRepo.isSharing ? Colors.green : theme.shadowColor;

    _speakerIcon = callRepo.isSpeaker
        ? CupertinoIcons.speaker_3
        : CupertinoIcons.speaker_1;
    _muteMicIcon =
        callRepo.isMicMuted ? CupertinoIcons.mic_off : CupertinoIcons.mic;
    _offVideoCamIcon = callRepo.mute_camera.value
        ? Icons.videocam_off_outlined
        : Icons.videocam_outlined;
    _screenShareIcon = callRepo.isSharing
        ? (isWindows
            ? Icons.screen_share_outlined
            : Icons.mobile_screen_share_outlined)
        : (isWindows
            ? Icons.stop_screen_share_outlined
            : Icons.mobile_screen_share_outlined);

    final width = MediaQuery.of(context).size.width;

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
              Container(
                padding: const EdgeInsets.all(10),
                height: 100,
                width: 100,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  heroTag: 66,
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: const Icon(
                    CupertinoIcons.phone_down_fill,
                    size: 50,
                    color: Colors.white,
                  ),
                  onPressed: () => _declineCall(),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return callRepo.isVideo
          ? isWindows
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: 25, right: 25, left: 25),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: width > 578 ? width / 2 : width,
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
                              width: boxSize,
                              height: boxSize,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: 22,
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      theme.cardColor.withOpacity(0),
                                  hoverColor: isAndroid
                                      ? theme.primaryColor.withOpacity(0.6)
                                      : null,
                                  onPressed: () => {},
                                  tooltip: _i18n.get("camera_switch"),
                                  child: Icon(
                                    CupertinoIcons.switch_camera,
                                    size: iconSize,
                                    color: Colors.white10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: boxSize,
                              height: boxSize,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: 33,
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      theme.cardColor.withOpacity(0),
                                  hoverColor:
                                      theme.primaryColor.withOpacity(0.6),
                                  onPressed: () => _offVideoCam(theme),
                                  tooltip: _i18n.get("camera"),
                                  child: Icon(
                                    _offVideoCamIcon,
                                    size: iconSize,
                                    color: _offVideoCamColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 75,
                            width: 75,
                            child: FloatingActionButton(
                              backgroundColor: Colors.red,
                              heroTag: 66,
                              elevation: 0,
                              shape: const CircleBorder(),
                              child: const Icon(
                                CupertinoIcons.phone_down_fill,
                                size: 35,
                                color: Colors.white,
                              ),
                              onPressed: () => widget.hangUp(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: boxSize,
                              height: boxSize,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: 44,
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      theme.cardColor.withOpacity(0),
                                  hoverColor:
                                      theme.primaryColor.withOpacity(0.6),
                                  onPressed: () => _muteMic(theme),
                                  tooltip: _i18n.get("mute_call"),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Icon(
                                      _muteMicIcon,
                                      size: iconSize,
                                      color: _muteMicColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // TODO(AmirHossein): enable it after fixing 3 issues in flutter-webRtc project itself, https://gitlab.iais.co/deliver/wiki/-/issues/425
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: boxSize,
                              height: boxSize,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: 55,
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      theme.cardColor.withOpacity(0),
                                  hoverColor:
                                      theme.primaryColor.withOpacity(0.6),
                                  onPressed: () => _shareScreen(theme, context),
                                  tooltip: _i18n.get("share_screen"),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Icon(
                                      _screenShareIcon,
                                      size: iconSize,
                                      color: _screenShareColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.only(bottom: 7, right: 10, left: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35.0),
                        color: theme.cardColor.withOpacity(0.8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 0,
                                ),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40.0,
                                        width: 40.0,
                                        child: FittedBox(
                                          child: FloatingActionButton(
                                            heroTag: 33,
                                            elevation: 0,
                                            shape: const CircleBorder(),
                                            backgroundColor:
                                                theme.cardColor.withOpacity(0),
                                            hoverColor: theme.primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () =>
                                                _offVideoCam(theme),
                                            child: Icon(
                                              _offVideoCamIcon,
                                              size: 35,
                                              color: _offVideoCamColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _i18n.get("camera"),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                height: 80,
                                width: 80,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.red,
                                  heroTag: 66,
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  child: const Icon(
                                    CupertinoIcons.phone_down_fill,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => widget.hangUp(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40.0,
                                        width: 40.0,
                                        child: FittedBox(
                                          child: FloatingActionButton(
                                            heroTag: 44,
                                            elevation: 0,
                                            shape: const CircleBorder(),
                                            backgroundColor:
                                                theme.cardColor.withOpacity(0),
                                            hoverColor: theme.primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () => _muteMic(theme),
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Icon(
                                                _muteMicIcon,
                                                size: 35,
                                                color: _muteMicColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(_i18n.get("mute_call"),
                                          style: theme.textTheme.labelSmall),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                width: 120,
                                height: 60,
                                child: Directionality(
                                  textDirection: _i18n.isPersian
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: FittedBox(
                                          child: FloatingActionButton(
                                            heroTag: 22,
                                            elevation: 0,
                                            shape: const CircleBorder(),
                                            backgroundColor:
                                                theme.cardColor.withOpacity(0),
                                            hoverColor: theme.primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () =>
                                                _switchCamera(theme),
                                            child: Icon(
                                              CupertinoIcons.switch_camera,
                                              size: 35,
                                              color: _switchCameraColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(_i18n.get("camera_switch"),
                                          style: theme.textTheme.labelSmall),
                                    ],
                                  ),
                                ),
                              ),
                              // TODO(AmirHossein): enable it after fixing 3 issues in flutter-webRtc project itself, https://gitlab.iais.co/deliver/wiki/-/issues/425
                              SizedBox(
                                width: 120,
                                height: 60,
                                child: Directionality(
                                  textDirection: _i18n.isPersian
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40.0,
                                        width: 40.0,
                                        child: FittedBox(
                                          child: FloatingActionButton(
                                            heroTag: 55,
                                            elevation: 0,
                                            shape: const CircleBorder(),
                                            backgroundColor:
                                                theme.cardColor.withOpacity(0),
                                            hoverColor: theme.primaryColor
                                                .withOpacity(0.6),
                                            onPressed: () =>
                                                _shareScreen(theme, context),
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Icon(
                                                _screenShareIcon,
                                                size: 35,
                                                color: _screenShareColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _i18n.get("share_screen"),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
          : Padding(
              padding: const EdgeInsets.only(bottom: 80, right: 50, left: 50),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: isWindows
                      ? width > 578
                          ? width / 2
                          : 3 * width / 4
                      : 99 * MediaQuery.of(context).size.width / 100,
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
                                      _speakerIcon,
                                      size: isAndroid ? 30 : 40,
                                      color: _speakerColor,
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
                                        _muteMicIcon,
                                        size: isAndroid ? 30 : 40,
                                        color: _muteMicColor,
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
    _switchCameraColor = !await callRepo.switchCamera()
        ? theme.buttonTheme.colorScheme!.primary
        : null;
    setState(() {});
  }

  void _muteMic(ThemeData theme) {
    _muteMicColor =
        callRepo.muteMicrophone() ? Colors.green : theme.shadowColor;
    setState(() {});
  }

  void _offVideoCam(ThemeData theme) {
    _offVideoCamColor =
        callRepo.muteCamera() ? theme.shadowColor : Colors.green;
    setState(() {});
  }

  Future<void> _shareScreen(ThemeData theme, BuildContext context) async {
    if (WebRTC.platformIsMacOS || WebRTC.platformIsWindows) {
      if (!callRepo.isSharing) {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source != null) {
          await callRepo.shareScreen(isWindows: true, source: source);
        }
      } else {
        await callRepo.shareScreen(isWindows: true);
      }
    } else {
      await callRepo.shareScreen();
    }
    _screenShareColor =
        callRepo.isSharing ? theme.buttonTheme.colorScheme!.primary : null;
    setState(() {});
  }

  void _enableSpeaker(ThemeData theme) {
    _speakerColor =
        callRepo.enableSpeakerVoice() ? Colors.green : theme.shadowColor;
    setState(() {});
  }

  void _acceptCall() {
    callRepo.acceptCall(callRepo.roomUid!);
  }

  void _declineCall() {
    callRepo.declineCall();
  }
}
