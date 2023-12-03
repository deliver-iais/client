import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final _iconsSize = isMobileDevice ? 20.0 : 30.0;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: AnimationSettings.superSlow,
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
          child: !isEnable
              ? PopupMenuButton<MediaDevice>(
                  icon: getEnableIconWithSize(
                    isEnable: isEnable,
                    enableIcon: CupertinoIcons.speaker_3,
                    disableIcon: CupertinoIcons.speaker_1,
                  ),
                  itemBuilder: (context) {
                    return [
                      if (!isDesktopNative)
                        PopupMenuItem<MediaDevice>(
                          child: ListTile(
                            leading: Icon(
                              CupertinoIcons.speaker_3,
                              color: isEnable
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary,
                            ),
                            title: Text(
                              _i18n.get("speaker"),
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          onTap: () => _enableSpeaker(theme),
                        ),
                      if (_audioOutputs != null)
                        ..._audioOutputs!.map((device) {
                          return PopupMenuItem<MediaDevice>(
                            value: device,
                            child: ListTile(
                              leading: (device.deviceId ==
                                      Hardware.instance.selectedAudioOutput
                                          ?.deviceId)
                                  ? Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: theme.colorScheme.secondary,
                                    )
                                  : Icon(
                                      CupertinoIcons.circle,
                                      color: theme.colorScheme.primary,
                                    ),
                              title: Text(device.label),
                            ),
                            onTap: () => _selectAudioOutput(device),
                          );
                        }).toList()
                    ];
                  },
                )
              : IconButton(
                  onPressed: () => _enableSpeaker(theme),
                  hoverColor: theme.colorScheme.primary.withOpacity(0.6),
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
            hoverColor: theme.colorScheme.primary.withOpacity(0.6),
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
            hoverColor: theme.colorScheme.primary.withOpacity(0.6),
            tooltip: _i18n.get("share_screen"),
            icon: getEnableIconWithSize(
              isEnable: isEnable,
              enableIcon: isDesktopDevice
                  ? Icons.screen_share_outlined
                  : Icons.mobile_screen_share_outlined,
              disableIcon: isDesktopDevice
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
    return Stack(
      alignment: Alignment.center,
      children: [
        StreamBuilder<double>(
          stream: _callRepo.speakingAmplitude,
          builder: (context, snapshot) {
            final amplitude = (snapshot.data ?? 0) * 64.0;
            final scale = !isEnable ? 0.0 : 1.2 + ((amplitude / 64.0));
            return AnimatedScale(
              duration: AnimationSettings.fast,
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: ACTIVE_COLOR.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                width: 50,
                height: 50,
              ),
            );
          },
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: getEnableBackgroundColor(isEnable: isEnable),
          child: isEnable
              ? PopupMenuButton<MediaDevice>(
                  icon: getEnableIconWithSize(
                    isEnable: isEnable,
                    enableIcon: CupertinoIcons.mic,
                    disableIcon: CupertinoIcons.mic_off,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<MediaDevice>(
                        child: ListTile(
                          leading: Icon(
                            CupertinoIcons.mic_off,
                            color: isEnable
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.primary,
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
                                      Hardware.instance.selectedAudioInput
                                          ?.deviceId)
                                  ? Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: theme.colorScheme.secondary,
                                    )
                                  : Icon(
                                      CupertinoIcons.circle,
                                      color: theme.colorScheme.primary,
                                    ),
                              title: Text(device.label),
                            ),
                            onTap: () => _selectAudioInput(device),
                          );
                        }).toList()
                    ];
                  },
                )
              : IconButton(
                  onPressed: () => _muteMic(theme),
                  hoverColor: theme.colorScheme.primary.withOpacity(0.6),
                  tooltip: _i18n.get("mute_call"),
                  icon: getEnableIconWithSize(
                    isEnable: isEnable,
                    enableIcon: CupertinoIcons.mic,
                    disableIcon: CupertinoIcons.mic_off,
                  ),
                ),
        ),
      ],
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
        hoverColor: theme.colorScheme.primary.withOpacity(0.6),
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
        onPressed: () =>
            isDesktopDevice ? _desktopDualVideo() : _switchCamera(theme),
        tooltip:
            isDesktopDevice ? _i18n.get("screen") : _i18n.get("camera_switch"),
        hoverColor: theme.colorScheme.primary.withOpacity(0.6),
        icon: Icon(
          isDesktopDevice ? desktopDualVideoIcon : CupertinoIcons.switch_camera,
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
      padding: const EdgeInsetsDirectional.only(bottom: 70, start: 50, end: 50),
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
            padding: const EdgeInsetsDirectional.symmetric(
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
                      padding: const EdgeInsetsDirectional.only(top: 3),
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
                      padding: const EdgeInsetsDirectional.only(top: 3),
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
                    buildAudioInputSelectionButton(theme),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 3),
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
    return Container(
      width: 500,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildSwitchingButton(theme),
          buildVideoingButton(theme),
          buildShareScreenButton(theme, context),
          buildEndCallButton(),
          buildAudioInputSelectionButton(theme),
          if (hasSpeakerCapability) buildSpeakerButton(theme),
        ],
      ),
    );
  }

  Padding _buildIncomingCallWidget(ThemeData theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 25),
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
              padding: const EdgeInsetsDirectional.all(45.0),
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

  Future<void> _shareScreen(ThemeData theme, BuildContext context) async {
    if (isDesktopNative) {
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
    if (isMobileNative) {
      await Permission.bluetoothConnect.request();
    }
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
  }

  Future<void> _selectAudioInput(MediaDevice device) async {
    _callRepo.enableMicrophone();
    await Hardware.instance.selectAudioInput(device);
    setState(() {});
  }

  Future<void> _selectAudioOutput(MediaDevice device) async {
    await Hardware.instance.selectAudioOutput(device);
    setState(() {});
  }
}
