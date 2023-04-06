import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/src/section.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class CallSettingsPage extends StatefulWidget {
  const CallSettingsPage({super.key});

  @override
  State<CallSettingsPage> createState() => _CallSettingsPageState();
}

class _CallSettingsPageState extends State<CallSettingsPage> {
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _i18n = GetIt.I.get<I18N>();
  final _logger = GetIt.I.get<Logger>();

  final _callService = GetIt.I.get<CallService>();

  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  List<CallServerItem> checkBoxListTileModel = [
    CallServerItem(
      checkboxId: 1,
      serverSetting: settings.localStunServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 2,
      serverSetting: settings.localTurnServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 3,
      serverSetting: settings.googleStunServerIsEnabled,
    ),
    CallServerItem(
      checkboxId: 4,
      serverSetting: settings.googleTurnServerIsEnabled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _getLocalStream(
      _callService.getVideoCallQualityDetails(settings.videoCallQuality.value),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _disposeLocalStream();
    _localRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("call")),
        ),
      ),
      body: FluidContainerWidget(
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: ListView(
            children: [
              if (_featureFlags.isVoiceCallAvailable())
                Section(
                  title: _i18n.get("voice_call_feature"),
                  children: [
                    Column(
                      children: [
                        SettingsTile.switchTile(
                          title: _i18n["low_network_usage"],
                          leading: const Icon(
                            CupertinoIcons.antenna_radiowaves_left_right,
                          ),
                          switchValue: settings.lowNetworkUsageVoiceCall.value,
                          enabled: !settings.lowNetworkUsageVoiceCall.enabled,
                          onToggle: (value) {
                            setState(() {
                              if (settings.highQualityCall.value) {
                                settings.highQualityCall.toggleValue();
                              }
                              settings.lowNetworkUsageVoiceCall.toggleValue();
                            });
                          },
                        ),
                        if (settings.lowNetworkUsageVoiceCall.value)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 18.0,
                              top: 4,
                              bottom: 10,
                            ),
                            child: Row(
                              children: [
                                if (PerformanceMonitor.isLessThanBalancedMode)
                                  const Icon(
                                    Icons.energy_savings_leaf_outlined,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      (isLarge(context) ? 0.45 : 0.7),
                                  child: Text(
                                    _i18n.get("low_network_usage_alert"),
                                    style: TextStyle(
                                      height: 1.2,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Column(
                      children: [
                        SettingsTile.switchTile(
                          title: _i18n["high_quality_call"],
                          leading: const Icon(
                            Icons.speed,
                          ),
                          switchValue: settings.highQualityCall.value,
                          enabled: settings.highQualityCall.enabled,
                          onToggle: (value) {
                            setState(() {
                              if (settings.lowNetworkUsageVoiceCall.value) {
                                settings.lowNetworkUsageVoiceCall.toggleValue();
                              }
                              settings.highQualityCall.toggleValue();
                            });
                          },
                        ),
                        if (settings.highQualityCall.value)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 18.0,
                              top: 4,
                              bottom: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      (isLarge(context) ? 0.45 : 0.7),
                                  child: Text(
                                    _i18n.get("high_quality_call_alert"),
                                    style: TextStyle(
                                      height: 1.2,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              Section(
                title: _i18n.get("video_call_feature"),
                children: [
                  Column(
                    children: [
                      SettingsTile(
                        title: _i18n.get("video_quality"),
                        leading: const Icon(Icons.speed),
                        trailing: const SizedBox.shrink(),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16.0,
                          ),
                          child: SegmentedButton<VideoCallQuality>(
                            segments: VideoCallQuality.values
                                .map(
                                  (e) => ButtonSegment<VideoCallQuality>(
                                    value: e,
                                    label: Text(e.buttonName),
                                  ),
                                )
                                .toList(),
                            selected: VideoCallQuality.values
                                .where(
                                  (e) => settings.videoCallQuality.value == e,
                                )
                                .toSet(),
                            showSelectedIcon: false,
                            onSelectionChanged: (set) {
                              final qualityDetails = _callService
                                  .getVideoCallQualityDetails(set.first);
                              settings.videoCallQuality.set(set.first);
                              _getLocalStream(qualityDetails);
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsetsDirectional.all(
                            20.0,
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: mainBorder,
                            boxShadow: DEFAULT_BOX_SHADOWS,
                          ),
                          width: MediaQuery.of(context).size.width * 2 / 3,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: mainBorder,
                                  clipBehavior: Clip.hardEdge,
                                  child: RTCVideoView(
                                    _localRenderer,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                    mirror: true,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${_i18n.get("resolution")}: ",
                                        ),
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Text(
                                            _callService
                                                .getVideoCallQualityDetails(
                                                  settings
                                                      .videoCallQuality.value,
                                                )
                                                .getResolution(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${_i18n.get("frame_rate")}: ${_callService.getVideoCallQualityDetails(settings.videoCallQuality.value).getFrameRate()}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SettingsTile.switchTile(
                        title: _i18n["low_network_usage"],
                        leading: const Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                        ),
                        switchValue: settings.lowNetworkUsageVideoCall.value,
                        enabled: !settings.lowNetworkUsageVoiceCall.enabled,
                        onToggle: (value) {
                          settings.lowNetworkUsageVideoCall.toggleValue();
                          if (settings.lowNetworkUsageVideoCall.value) {
                            setState(() {
                              if (settings.videoCallQuality.value.level >
                                  VideoCallQuality.MEDIUM.level) {
                                settings.videoCallQuality
                                    .set(VideoCallQuality.MEDIUM);
                                final qualityDetails =
                                _callService.getVideoCallQualityDetails(
                                  VideoCallQuality.MEDIUM,
                                );
                                _getLocalStream(qualityDetails);
                              }
                            });
                          } else {
                            final qualityDetails =
                                _callService.getVideoCallQualityDetails(
                              settings.videoCallQuality.value,
                            );
                            _getLocalStream(qualityDetails);
                          }
                        },
                      ),
                      if (settings.lowNetworkUsageVideoCall.value)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 18.0,
                            top: 4,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              if (PerformanceMonitor.isLessThanBalancedMode)
                                const Icon(
                                  Icons.energy_savings_leaf_outlined,
                                  size: 20,
                                  color: Colors.green,
                                ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    (isLarge(context) ? 0.45 : 0.7),
                                child: Text(
                                  _i18n.get("low_network_usage_alert"),
                                  style: TextStyle(
                                    height: 1.2,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _getLocalStream(
    VideoCallQualityDetails videoCallQualityDetails,
  ) async {
    final mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': videoCallQualityDetails.width.toString(),
          'minHeight': videoCallQualityDetails.height.toString(),
          'maxWidth': videoCallQualityDetails.width.toString(),
          'maxHeight': videoCallQualityDetails.height.toString(),
          'minFrameRate': videoCallQualityDetails.getFrameRate().toString(),
          'maxFrameRate': videoCallQualityDetails.getFrameRate().toString(),
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      await _disposeLocalStream();
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      _logger.e(e);
    }
    setState(() {});
  }

  Future<void> _disposeLocalStream() async {
    try {
      if (_localStream != null) {
        _localStream!.getTracks().forEach((element) async {
          await element.stop();
        });
        await _localStream!.dispose();
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}

class CallServerItem {
  int checkboxId;
  BooleanPersistent serverSetting;

  CallServerItem({
    required this.checkboxId,
    required this.serverSetting,
  });
}
