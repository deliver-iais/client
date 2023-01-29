import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/shareScreen/screen_select_dialog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class CallBottomRow extends StatefulWidget {
  final void Function() hangUp;
  final bool isIncomingCall;
  final CallStatus callStatus;

  const CallBottomRow({
    super.key,
    required this.hangUp,
    required this.callStatus,
    this.isIncomingCall = false,
  });

  @override
  CallBottomRowState createState() => CallBottomRowState();
}

class CallBottomRowState extends State<CallBottomRow>
    with SingleTickerProviderStateMixin {
  final _i18n = GetIt.I.get<I18N>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _iconsSize = isAndroid ? 20.0 : 30.0;

  Color? _switchCameraColor;
  Color? _switchCameraBackgroundColor;

  // ignore: unused_field
  Color? _screenShareColor;
  Color? _muteMicColor;

  //Color? _screenShareBackgroundColor;
  Color? _muteMicBackgroundColor;

  // ignore: unused_field
  IconData? _screenShareIcon;
  IconData? _muteMicIcon;
  IconData? _desktopDualVideoIcon;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: SUPER_SLOW_ANIMATION_DURATION,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    initializeIcons();

    if (callBottomStatus(widget.callStatus)) {
      return _buildIncomingCallWidget(theme);
    } else {
      return _callRepo.isVideo
          ? _buildVideoCallWidget(theme, context)
          : _buildVoiceCallWidget(theme);
    }
  }

  Widget _buildVoiceCallWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70, right: 50, left: 50),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ],
            color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
            borderRadius: BorderRadius.circular(35.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: _callRepo.isSpeaker,
                      builder: (context, snapshot) {
                        return CircleAvatar(
                          radius: 25,
                          backgroundColor: _callRepo.isSpeaker.value
                              ? grayColor
                              : Colors.white,
                          child: IconButton(
                            onPressed: () => _enableSpeaker(theme),
                            icon: Icon(
                              snapshot.data ?? false
                                  ? CupertinoIcons.speaker_3
                                  : CupertinoIcons.speaker_1,
                              size: _iconsSize,
                              color: snapshot.data ?? false
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _i18n.get("speaker"),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(
                            CupertinoIcons.phone_down_fill,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () => widget.hangUp(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _i18n.get("end_call"),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: _muteMicBackgroundColor,
                      child: IconButton(
                        hoverColor: theme.primaryColor.withOpacity(0.6),
                        onPressed: () => _muteMic(theme),
                        tooltip: _i18n.get("mute_call"),
                        icon: Icon(
                          _muteMicIcon,
                          size: _iconsSize,
                          color: _muteMicColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _i18n.get("mute_call"),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCallWidget(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, right: 20, left: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 500,
          padding: const EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                backgroundColor: _switchCameraBackgroundColor,
                child: IconButton(
                  onPressed: () =>
                      isDesktop ? _desktopDualVideo() : _switchCamera(theme),
                  tooltip: isDesktop
                      ? _i18n.get("screen")
                      : _i18n.get("camera_switch"),
                  icon: Icon(
                    isDesktop
                        ? _desktopDualVideoIcon
                        : CupertinoIcons.switch_camera,
                    size: _iconsSize,
                    color: isDesktop ? theme.shadowColor : _switchCameraColor,
                  ),
                ),
              ),
              StreamBuilder<Object>(
                stream: _callRepo.videoing,
                builder: (context, snapshot) {
                  return CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        _callRepo.videoing.value ? grayColor : Colors.white,
                    child: IconButton(
                      onPressed: () => _offVideoCam(theme),
                      tooltip: _i18n.get("camera"),
                      icon: Icon(
                        _callRepo.videoing.value
                            ? Icons.videocam_outlined
                            : Icons.videocam_off_outlined,
                        size: _iconsSize,
                        color: _callRepo.videoing.value
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.phone_down_fill,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => widget.hangUp(),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: _muteMicBackgroundColor,
                child: IconButton(
                  hoverColor: theme.primaryColor.withOpacity(0.6),
                  onPressed: () => _muteMic(theme),
                  tooltip: _i18n.get("mute_call"),
                  icon: Icon(
                    _muteMicIcon,
                    size: _iconsSize,
                    color: _muteMicColor,
                  ),
                ),
              ),
              // CircleAvatar(
              //   radius: 25,
              //   backgroundColor: _screenShareBackgroundColor,
              // IconButton(
              //   onPressed: () => _shareScreen(theme, context),
              //   tooltip: _i18n.get("share_screen"),
              //   icon: Icon(
              //     _screenShareIcon,
              //     size: _iconsSize,
              //     color: _screenShareColor,
              //   ),
              // ),
              // ),
              if (isAndroid || isIOS)
                StreamBuilder<bool>(
                  stream: _callRepo.isSpeaker,
                  builder: (context, snapshot) {
                    return CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          _callRepo.isSpeaker.value ? grayColor : Colors.white,
                      child: IconButton(
                        onPressed: () => _enableSpeaker(theme),
                        icon: Icon(
                          snapshot.data ?? false
                              ? CupertinoIcons.speaker_3
                              : CupertinoIcons.speaker_1,
                          size: _iconsSize,
                          color: snapshot.data ?? false
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildIncomingCallWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 150,
              child: IconButton(
                hoverColor: Colors.transparent,
                icon: Lottie.asset(
                  "assets/animations/accepting_call.json",
                  width: 150,
                  height: 150,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        const ['**'],
                        value:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                onPressed: () => _acceptCall(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(45.0),
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      CupertinoIcons.phone_down_fill,
                      size: 35,
                      color: theme.errorColor,
                    ),
                    onPressed: () => _declineCall(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool callBottomStatus(CallStatus callStatus) {
    switch (callStatus) {
      case CallStatus.CREATED:
        return !_callRepo.isCaller;
      case CallStatus.IS_RINGING:
        return widget.isIncomingCall;
      case CallStatus.DECLINED:
      case CallStatus.BUSY:
      case CallStatus.ENDED:
      case CallStatus.NO_CALL:
      case CallStatus.ACCEPTED:
      case CallStatus.CONNECTING:
      case CallStatus.RECONNECTING:
      case CallStatus.CONNECTED:
      case CallStatus.DISCONNECTED:
      case CallStatus.FAILED:
      case CallStatus.NO_ANSWER:
        return false;
    }
  }

  void initializeIcons() {
    _muteMicColor = _callRepo.isMicMuted ? Colors.black : Colors.white;
    _switchCameraColor =
        _callRepo.switching.value ? Colors.white : Colors.black;
    _screenShareColor = _callRepo.isSharing ? Colors.black : Colors.white;

    _muteMicBackgroundColor = _callRepo.isMicMuted ? Colors.white : grayColor;
    _switchCameraBackgroundColor =
        _callRepo.switching.value ? grayColor : Colors.white;
    // _screenShareBackgroundColor =
    //     _callRepo.isSharing ? grayColor : Colors.white;

    _muteMicIcon =
        _callRepo.isMicMuted ? CupertinoIcons.mic_off : CupertinoIcons.mic;
    _screenShareIcon = _callRepo.isSharing
        ? (isDesktop
            ? Icons.screen_share_outlined
            : Icons.mobile_screen_share_outlined)
        : (isDesktop
            ? Icons.stop_screen_share_outlined
            : Icons.mobile_screen_share_outlined);

    _desktopDualVideoIcon = _callRepo.desktopDualVideo.value
        ? CupertinoIcons.square_line_vertical_square
        : CupertinoIcons.rectangle;
  }

  Future<void> _switchCamera(ThemeData theme) async {
    await _callRepo.switchCamera();
    setState(() {});
  }

  void _muteMic(ThemeData theme) {
    _callRepo.muteMicrophone();
    setState(() {});
  }

  void _offVideoCam(ThemeData theme) {
    _callRepo.muteCamera();
    setState(() {});
  }

  // ignore: unused_element
  Future<void> _shareScreen(ThemeData theme, BuildContext context) async {
    if (WebRTC.platformIsMacOS || WebRTC.platformIsWindows) {
      if (!_callRepo.isSharing) {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source != null) {
          await _callRepo.shareScreen(isWindows: true, source: source);
        }
      } else {
        await _callRepo.shareScreen(isWindows: true);
      }
    } else {
      await _callRepo.shareScreen();
    }
    setState(() {});
  }

  void _enableSpeaker(ThemeData theme) {
    _callRepo.enableSpeakerVoice();
    setState(() {});
  }

  void _desktopDualVideo() {
    _callRepo.toggleDesktopDualVideo();
    setState(() {});
  }

  void _acceptCall() {
    _callRepo.acceptCall(_callRepo.roomUid!);
  }

  void _declineCall() {
    _callRepo.declineCall();
  }
}
