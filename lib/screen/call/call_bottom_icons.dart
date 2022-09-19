import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/shareScreen/screen_select_dialog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';

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

class CallBottomRowState extends State<CallBottomRow>
    with SingleTickerProviderStateMixin {
  final _i18n = GetIt.I.get<I18N>();
  final _iconsSize = isAndroid ? 30.0 : 40.0;


  Color? _switchCameraColor;
  Color? _offVideoCamColor;
  Color? _speakerColor;
  Color? _screenShareColor;
  Color? _muteMicColor;

  IconData? _offVideoCamIcon;
  IconData? _speakerIcon;
  IconData? _screenShareIcon;
  IconData? _muteMicIcon;
  IconData? _desktopDualVideoIcon;

  final callRepo = GetIt.I.get<CallRepo>();

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

    if (widget.isIncomingCall) {
      return _buildIncomingCallWidget(theme);
    } else {
      return callRepo.isVideo
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
          width: isWindows ? 600 : 400,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: theme.colorScheme.outline.withOpacity(0.6),
              ),
            ],
            color:  theme.colorScheme.tertiaryContainer,
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
                    FloatingActionButton(
                      heroTag: "1",
                      elevation: 0,
                      shape: const CircleBorder(),
                      backgroundColor: Colors.transparent,
                      onPressed: () => _enableSpeaker(theme),
                      child: Icon(
                        _speakerIcon,
                        size: isAndroid ? 30 : 40,
                        color: _speakerColor,
                      ),
                    ),
                    Text(
                      _i18n.get("speaker"),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                SizedBox(
                  height: isAndroid ? 65 : 80,
                  width: isAndroid ? 65 : 80,
                  child: FloatingActionButton(
                    backgroundColor: theme.colorScheme.tertiary,
                    heroTag: "2",
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: Icon(
                      CupertinoIcons.phone_down_fill,
                      size: isAndroid ? 37 : 50,
                      color: Colors.white,
                    ),
                    onPressed: () => widget.hangUp(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "3",
                      elevation: 0,
                      shape: const CircleBorder(),
                      backgroundColor: theme.cardColor.withOpacity(0),
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
                    Text(
                      _i18n.get("mute_call"),
                      style: theme.textTheme.titleSmall,
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: theme.colorScheme.outline.withOpacity(0.6),
              ),
            ],
            borderRadius: BorderRadius.circular(35.0),
           color:  theme.colorScheme.tertiaryContainer,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                heroTag: 22,
                elevation: 0,
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                onPressed: () =>
                    isDesktop ? _desktopDualVideo() : _switchCamera(theme),
                tooltip: isDesktop
                    ? _i18n.get("screen")
                    : _i18n.get("camera_switch"),
                child: Icon(
                  isDesktop
                      ? _desktopDualVideoIcon
                      : CupertinoIcons.switch_camera,
                  size: _iconsSize,
                  color: isDesktop ? theme.shadowColor : _switchCameraColor,
                ),
              ),
              FloatingActionButton(
                heroTag: 33,
                elevation: 0,
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                onPressed: () => _offVideoCam(theme),
                tooltip: _i18n.get("camera"),
                child: Icon(
                  _offVideoCamIcon,
                  size: _iconsSize,
                  color: _offVideoCamColor,
                ),
              ),

              SizedBox(
                width: 65,
                height: 65,
                child: FloatingActionButton(
                  backgroundColor:  theme.colorScheme.tertiary,
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
              FloatingActionButton(
                heroTag: 44,
                elevation: 0,
                shape: const CircleBorder(),
                backgroundColor: theme.cardColor.withOpacity(0),
                hoverColor: theme.primaryColor.withOpacity(0.6),
                onPressed: () => _muteMic(theme),
                tooltip: _i18n.get("mute_call"),
                child: Icon(
                  _muteMicIcon,
                  size: _iconsSize,
                  color: _muteMicColor,
                ),
              ),
              FloatingActionButton(
                heroTag: 55,
                elevation: 0,
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                onPressed: () => _shareScreen(theme, context),
                tooltip: _i18n.get("share_screen"),
                child: Icon(
                  _screenShareIcon,
                  size: _iconsSize,
                  color: _screenShareColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildIncomingCallWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 80,
              height: 80,
              child: FloatingActionButton(
                heroTag: 11,
                backgroundColor: Colors.white,
                elevation: 0,
                shape: const CircleBorder(),
                child: Icon(
                  CupertinoIcons.phone_fill,
                  size: 50,
                  color: ACTIVE_COLOR,
                ),
                onPressed: () => _acceptCall(),
              ),
            ),
            SizedBox(
              height: 80,
              width: 80,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                heroTag: 66,
                elevation: 0,
                shape: const CircleBorder(),
                child: Icon(
                  CupertinoIcons.phone_down_fill,
                  size: 50,
                  color: theme.errorColor,
                ),
                onPressed: () => _declineCall(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void initializeIcons() {
    final theme = Theme.of(context);
    _speakerColor = callRepo.isSpeaker ? theme.primaryColor : theme.colorScheme.onTertiaryContainer;
    _muteMicColor =
        callRepo.isMicMuted ? theme.primaryColor : theme.colorScheme.onTertiaryContainer;
    _offVideoCamColor =
        callRepo.mute_camera.value ?  theme.colorScheme.onTertiaryContainer:theme.primaryColor;
    _switchCameraColor =
        callRepo.switching.value ? theme.primaryColor : theme.colorScheme.onTertiaryContainer;
    _screenShareColor =
        callRepo.isSharing ? theme.primaryColor : theme.colorScheme.onTertiaryContainer;

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

    _desktopDualVideoIcon = callRepo.desktopDualVideo.value
        ? CupertinoIcons.square_line_vertical_square
        : CupertinoIcons.rectangle;
  }

  Future<void> _switchCamera(ThemeData theme) async {
    await callRepo.switchCamera();
    setState(() {});
  }

  void _muteMic(ThemeData theme) {
    callRepo.muteMicrophone();
    setState(() {});
  }

  void _offVideoCam(ThemeData theme) {
    callRepo.muteCamera();
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
    setState(() {});
  }

  void _enableSpeaker(ThemeData theme) {
    callRepo.enableSpeakerVoice();
    setState(() {});
  }

  void _desktopDualVideo() {
    callRepo.toggleDesktopDualVideo();
    setState(() {});
  }

  void _acceptCall() {
    callRepo.acceptCall(callRepo.roomUid!);
  }

  void _declineCall() {
    callRepo.declineCall();
  }
}
