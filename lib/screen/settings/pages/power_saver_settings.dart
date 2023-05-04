import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class PowerSaverSettingsPage extends StatefulWidget {
  const PowerSaverSettingsPage({super.key});

  @override
  PowerSaverSettingsPageState createState() => PowerSaverSettingsPageState();
}

class PowerSaverSettingsPageState extends State<PowerSaverSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  late final StreamSubscription<dynamic> streamSubscription;

  @override
  void initState() {
    streamSubscription = MergeStream<dynamic>([
      settings.performanceMode.stream,
      settings.powerSaverBatteryLevel.stream,
      settings.batteryMonitor.batteryLevel.stream,
      settings.batteryMonitor.batteryState.stream,
    ]).listen((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n["power_saver"]),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            children: [
              Section(
                title: _i18n.get("performance"),
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                    child: Column(
                      children: [
                        SettingsTile(
                          title: _i18n.get("performance"),
                          leading: const Icon(Icons.speed),
                          trailing: const SizedBox.shrink(),
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SegmentedButton<PerformanceMode>(
                              segments: PerformanceMode.values
                                  .map(
                                    (e) => ButtonSegment<PerformanceMode>(
                                      value: e,
                                      label: Text(e.buttonName),
                                    ),
                                  )
                                  .toList(),
                              selected: PerformanceMode.values
                                  .where(
                                    (e) => settings.performanceMode.value == e,
                                  )
                                  .toSet(),
                              showSelectedIcon: false,
                              onSelectionChanged: (set) {
                                setState(() {
                                  settings.performanceMode.set(set.first);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<BatteryState>(
                    stream: settings.batteryMonitor.batteryState,
                    builder: (context, snapshot) {
                      if (settings.batteryMonitor.isNotAvailable) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          SettingsTile(
                            enabled: !PerformanceMonitor.isLessThanBalancedMode,
                            title: _i18n.get("automatic_power_saver_mode"),
                            leading: const Icon(
                              Icons.energy_savings_leaf_outlined,
                            ),
                            trailing: StreamBuilder<int>(
                              stream: settings.batteryMonitor.batteryLevel,
                              builder: (context, snapshot) {
                                final batteryLevel = snapshot.data ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "$batteryLevel%",
                                        style: TextStyle(
                                          color: PerformanceMonitor
                                                  .isLessThanBalancedMode
                                              ? theme.disabledColor
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        CupertinoIcons.battery_full,
                                        color: PerformanceMonitor
                                                .isLessThanBalancedMode
                                            ? theme.disabledColor
                                            : null,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: p24,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "0% - ${_i18n["off"]}",
                                  style: TextStyle(
                                    color: PerformanceMonitor
                                            .isLessThanBalancedMode
                                        ? theme.disabledColor
                                        : null,
                                  ),
                                ),
                                Expanded(
                                  child: StreamBuilder<int>(
                                    stream:
                                        settings.powerSaverBatteryLevel.stream,
                                    builder: (context, snapshot) {
                                      final value =
                                          (snapshot.data ?? 0).toDouble();

                                      return Slider(
                                        divisions: 10,
                                        value: value,
                                        max: 100,
                                        label: batteryPercentLabel(
                                          snapshot.data ?? 0,
                                        ),
                                        onChanged: PerformanceMonitor
                                                .isLessThanBalancedMode
                                            ? null
                                            : (newValue) {
                                                settings.powerSaverBatteryLevel
                                                    .set(
                                                  newValue.toInt(),
                                                );
                                              },
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  "100% - ${_i18n["always"]}",
                                  style: TextStyle(
                                    color: PerformanceMonitor
                                            .isLessThanBalancedMode
                                        ? theme.disabledColor
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Section(
                title: _i18n.get("options"),
                children: [
                  SettingsTile.switchTile(
                    title: _i18n.get("show_link_preview"),
                    leading: const Icon(CupertinoIcons.link),
                    switchValue: settings.showLinkPreview.value,
                    enabled: settings.showLinkPreview.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showLinkPreview.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["repeat_animated_emojis"],
                    leading: const Icon(Icons.animation),
                    switchValue: settings.repeatAnimatedEmoji.value,
                    enabled: settings.repeatAnimatedEmoji.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.repeatAnimatedEmoji.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["repeat_animated_stickers"],
                    leading: const Icon(Icons.animation),
                    switchValue: settings.repeatAnimatedStickers.value,
                    enabled: settings.repeatAnimatedStickers.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.repeatAnimatedStickers.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_animated_emojis"],
                    leading: const Icon(Icons.emoji_emotions_outlined),
                    switchValue: settings.showAnimatedEmoji.value,
                    enabled: settings.showAnimatedEmoji.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showAnimatedEmoji.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_background"],
                    leading: const Icon(Icons.image_not_supported_outlined),
                    switchValue: settings.showRoomBackground.value,
                    enabled: settings.showRoomBackground.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showRoomBackground.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_blurred_components"],
                    leading: const Icon(Icons.flip_to_back),
                    switchValue: settings.showBlurredComponents.value,
                    enabled: settings.showBlurredComponents.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showBlurredComponents.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_message_details"],
                    leading: const Icon(Icons.message_outlined),
                    switchValue: settings.showMessageDetails.value,
                    enabled: settings.showMessageDetails.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showMessageDetails.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_animations"],
                    leading: const Icon(Icons.animation),
                    switchValue: settings.showAnimations.value,
                    enabled: settings.showAnimations.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showAnimations.toggleValue(),
                      );
                    },
                  ),
                  if (false)
                    // TODO(bitbeter): Add settings usage for show animated avatars.
                    // ignore: dead_code
                    SettingsTile.switchTile(
                      title: _i18n["show_animated_avatars"],
                      leading: const Icon(Icons.person_4_rounded),
                      switchValue: settings.showAnimatedAvatars.value,
                      enabled: settings.showAnimatedAvatars.enabled,
                      onToggle: (value) {
                        setState(
                          () => settings.showAnimatedAvatars.toggleValue(),
                        );
                      },
                    ),
                  SettingsTile.switchTile(
                    title: _i18n["show_avatar_images"],
                    leading: const Icon(CupertinoIcons.profile_circled),
                    switchValue: settings.showAvatarImages.value,
                    enabled: settings.showAvatarImages.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showAvatarImages.toggleValue(),
                      );
                    },
                  ),
                  SettingsTile.switchTile(
                    title: _i18n["show_avatars"],
                    leading:
                        const Icon(CupertinoIcons.circle_bottomthird_split),
                    switchValue: settings.showAvatars.value,
                    enabled: settings.showAvatars.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showAvatars.toggleValue(),
                      );
                    },
                  ),
                  if (!isMacOSNative)
                    SettingsTile.switchTile(
                      title: _i18n["parse_and_show_google_emojis"],
                      leading: const Icon(Icons.emoji_events_outlined),
                      switchValue: settings.parseAndShowGoogleEmojis.value,
                      enabled: settings.parseAndShowGoogleEmojis.enabled,
                      onToggle: (value) {
                        setState(
                          () => settings.parseAndShowGoogleEmojis.toggleValue(),
                        );
                      },
                    ),
                  SettingsTile.switchTile(
                    title: _i18n["show_animations_with_higher_frame_rates"],
                    leading: const Icon(CupertinoIcons.flame),
                    switchValue: settings.showWsWithHighFrameRate.value,
                    enabled: settings.showWsWithHighFrameRate.enabled,
                    onToggle: (value) {
                      setState(
                        () => settings.showWsWithHighFrameRate.toggleValue(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String batteryPercentLabel(int percent) {
    if (percent <= 0) {
      return _i18n["off"];
    } else if (percent >= 99) {
      return _i18n["always"];
    } else {
      return percent.toString();
    }
  }
}
