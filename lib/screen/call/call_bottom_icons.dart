import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:livekit_client/livekit_client.dart';

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
    with CustomPopupMenu, SingleTickerProviderStateMixin {
  final _i18n = GetIt.I.get<I18N>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _iconsSize = isAndroid ? 20.0 : 30.0;

  List<MediaDevice>? _audioInputs;

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

    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (callBottomStatus(widget.callStatus)) {
      return _buildIncomingCallWidget(theme);
    } else {
      return _callRepo.isVideo
          ? _buildVideoCallWidget(theme, context)
          : _buildVoiceCallWidget(theme);
    }
  }

  Icon getEnableIconWithSize({
    required bool isEnable,
    required IconData enableIcon,
    required IconData disableIcon,
  }) =>
      getEnableIcon(
        isEnable: isEnable,
        enableIcon: enableIcon,
        disableIcon: disableIcon,
        size: _iconsSize,
      );

  Widget buildSpeakerButton(ThemeData theme) {
    return StreamBuilder<bool>(
      stream: _callRepo.isSpeaker,
      builder: (context, snapshot) {
        final isEnable = snapshot.data ?? false;

        return CircleAvatar(
          radius: 25,
          backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
          child: IconButton(
            onPressed: () => _enableSpeaker(theme),
            hoverColor: theme.primaryColor.withOpacity(0.6),
            tooltip: _i18n.get("speaker"),
            icon: getEnableIconWithSize(
              isEnable: isEnable,
              enableIcon: CupertinoIcons.speaker_3,
              disableIcon: CupertinoIcons.speaker_1,
            ),
          ),
        );
      },
    );
  }

  Widget buildVideoingButton(ThemeData theme) {
    return StreamBuilder<bool>(
      stream: _callRepo.videoing,
      builder: (context, snapshot) {
        final isEnable = snapshot.data ?? false;

        return CircleAvatar(
          radius: 25,
          backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
          child: IconButton(
            onPressed: () => _offVideoCam(theme),
            hoverColor: theme.primaryColor.withOpacity(0.6),
            tooltip: _i18n.get("camera"),
            icon: getEnableIconWithSize(
              isEnable: isEnable,
              enableIcon: Icons.videocam_outlined,
              disableIcon: Icons.videocam_off_outlined,
            ),
          ),
        );
      },
    );
  }

  Widget buildShareScreenButton(ThemeData theme, BuildContext context) {
    return StreamBuilder<bool>(
      stream: _callRepo.sharing,
      builder: (c, snapshot) {
        final isEnable = snapshot.data ?? false;

        return CircleAvatar(
          radius: 25,
          backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
          child: IconButton(
            onPressed: () => _shareScreen(theme, context),
            hoverColor: theme.primaryColor.withOpacity(0.6),
            tooltip: _i18n.get("share_screen"),
            icon: getEnableIconWithSize(
              isEnable: isEnable,
              enableIcon: isDesktop
                  ? Icons.screen_share_outlined
                  : Icons.mobile_screen_share_outlined,
              disableIcon: isDesktop
                  ? Icons.stop_screen_share_outlined
                  : Icons.mobile_screen_share_outlined,
            ),
          ),
        );
      },
    );
  }

  Widget buildAudioInputSelectionButton(ThemeData theme) {
    final isEnable = !_callRepo.isMicMuted;

    return CircleAvatar(
      radius: 25,
      backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanDown: (e) => storePosition(e),
        child: IconButton(
          hoverColor: theme.primaryColor.withOpacity(0.6),
          tooltip: _i18n.get("call_audio"),
          icon: getEnableIconWithSize(
            isEnable: isEnable,
            enableIcon: CupertinoIcons.mic,
            disableIcon: CupertinoIcons.mic_off,
          ),
          onPressed: () => this.showMenu(
            context: context,
            items: [
              PopupMenuItem<MediaDevice>(
                child: ListTile(
                  leading: const Icon(
                    CupertinoIcons.mic_off,
                    color: Colors.white,
                  ),
                  title: Text(
                    _i18n.get("mute_call"),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                onTap: () => _muteMic(theme),
              ),
              if (_audioInputs != null)
                ..._audioInputs!.map((device) {
                  return PopupMenuItem<MediaDevice>(
                    value: device,
                    child: ListTile(
                      leading: (device.deviceId ==
                              Hardware.instance.selectedAudioInput?.deviceId)
                          ? const Icon(
                              CupertinoIcons.checkmark_circle,
                              color: Colors.white,
                            )
                          : const Icon(
                              CupertinoIcons.circle,
                              color: Colors.white,
                            ),
                      title: Text(device.label),
                    ),
                  );
                }).toList()
            ],
          ).then(
            (device) => _selectAudioInput(device!),
          ),
        ),
      ),
    );
  }

  void selectAudioTrack(String key) {
    _callRepo.selectAudioTrackById = key;
  }

  Widget buildMicButton(ThemeData theme) {
    final isEnable = !_callRepo.isMicMuted;

    return CircleAvatar(
      radius: 25,
      backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
      child: IconButton(
        onPressed: () => _muteMic(theme),
        hoverColor: theme.primaryColor.withOpacity(0.6),
        tooltip: _i18n.get("mute_call"),
        icon: getEnableIconWithSize(
          isEnable: isEnable,
          enableIcon: CupertinoIcons.mic,
          disableIcon: CupertinoIcons.mic_off,
        ),
      ),
    );
  }

  Widget buildSwitchingButton(ThemeData theme) {
    final desktopDualVideoIcon = _callRepo.desktopDualVideo.value
        ? CupertinoIcons.square_line_vertical_square
        : CupertinoIcons.rectangle;

    return CircleAvatar(
      radius: 25,
      backgroundColor: getEnableBackgroundColor(isEnable: false),
      child: IconButton(
        onPressed: () => isDesktop ? _desktopDualVideo() : _switchCamera(theme),
        tooltip: isDesktop ? _i18n.get("screen") : _i18n.get("camera_switch"),
        hoverColor: theme.primaryColor.withOpacity(0.6),
        icon: Icon(
          isDesktop ? desktopDualVideoIcon : CupertinoIcons.switch_camera,
          size: _iconsSize,
          color: getEnableColor(isEnable: false),
        ),
      ),
    );
  }

  Widget buildEndCallButton() {
    return SizedBox(
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
    );
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
                    buildSpeakerButton(theme),
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
                    buildEndCallButton(),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        _i18n.get("end_call"),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                if (!isDesktop)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buildMicButton(theme),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _i18n.get("mute_call"),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                if (isDesktopOrWeb)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buildAudioInputSelectionButton(theme),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _i18n.get("call_audio"),
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
              buildSwitchingButton(theme),
              buildVideoingButton(theme),
              if (isDesktopOrWeb) buildShareScreenButton(theme, context),
              buildEndCallButton(),
              buildMicButton(theme),
              if (isAndroid || isIOS) buildSpeakerButton(theme),
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
              width: 120,
              height: 120,
              child: IconButton(
                icon: const Ws.asset("assets/animations/accepting_call.ws"),
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
                      color: theme.colorScheme.error,
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
    if (isDesktop) {
      if (!_callRepo.isSharing) {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source != null) {
          await _callRepo.shareScreen(source: source);
        }
      } else {
        await _callRepo.shareScreen();
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

  Future<void> _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
  }

  Future<void> _selectAudioInput(MediaDevice device) async {
    _callRepo.enableMicrophone();
    await Hardware.instance.selectAudioInput(device);
    setState(() {});
  }
}
