import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/release_badge.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:rxdart/rxdart.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

const DEFAULT_FONT_SIZE = 20;
const MIN_FONT_SIZE = 0.85;
const MAX_FONT_SIZE = 1.45;

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();

  final _i18n = GetIt.I.get<I18N>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _idSubject = BehaviorSubject.seeded(0);
  final _controller = ScrollController();

  List<Message> messages = [];

  void createMessages() {
    final cUser = _authRepo.currentUserUid.asString();
    messages = [
      cm(1, cUser, FAKE_USER_UID.asString(), "سلام"),
      cm(
        2,
        cUser,
        FAKE_USER_UID.asString(),
        "امروز میخواستیم با بچه ها بریم فوتبال، میای ؟ اگر نمیای که یه خبری بی زحمت بده [لینک محل ورزشگاه](https://nshn.ir/68sbvXhTWxVYuZ) ",
      ),
      cm(
        3,
        FAKE_USER_UID.asString(),
        cUser,
        "👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋👋",
        replyId: 1,
      ),
      cm(4, FAKE_USER_UID.asString(), cUser, "حتما، چه ساعتیه ؟!", replyId: 2),
      cm(
        5,
        cUser,
        FAKE_USER_UID.asString(),
        "👌",
        replyId: 4,
      ),
      cm(
        6,
        cUser,
        FAKE_USER_UID.asString(),
        "ایول\\n \\n ساعت ۹ شب، ورزشگاه. منتظرتیم",
      ),
    ];
  }

  List<Widget> createFakeMessages() {
    return [
      buildMessageBox(1),
      buildMessageBox(2),
      buildMessageBox(3),
      buildMessageBox(4),
      buildMessageBox(5),
      buildMessageBox(6),
    ];
  }

  Message cm(
    int id,
    String from,
    String to,
    String text, {
    int? replyId,
  }) {
    return Message(
      id: id,
      type: MessageType.TEXT,
      from: from.asUid(),
      replyToId: replyId ?? 0,
      to: to.asUid(),
      time: id,
      json: '{"1":"$text"}',
      packetId: '',
      roomUid: FAKE_USER_UID,
    );
  }

  MessageBrief? cfm(int id) {
    if (id <= 0) {
      return null;
    }

    final m = messages[id - 1];
    final text = m.json.toText().text;

    return MessageBrief(
      roomUid: m.roomUid.asString(),
      packetId: m.packetId,
      id: m.id ?? 0,
      time: m.time,
      from: m.from.asString(),
      to: m.to.asString(),
      text: text,
      type: m.type,
    );
  }

  Widget buildMessageBox(int msgId) {
    final msg = messages[msgId - 1];
    final replyId = msg.replyToId;
    Message? bMsg;

    if (msgId > 1) {
      bMsg = messages[msgId - 2];
    }

    return LayoutBuilder(
      builder: (context, snapshot) => BuildMessageBox(
        message: msg,
        messageReplyBrief: cfm(replyId),
        messageBefore: bMsg,
        roomId: FAKE_USER_UID,
        lastSeenMessageId: messages.length - 1,
        pinMessages: const [],
        hasPermissionInGroup: false,
        hasPermissionInChannel: BehaviorSubject.seeded(false),
        width: snapshot.maxWidth,
        menuDisabled: true,
        onEdit: () {},
        onPin: () {},
        onUnPin: () {},
        onReply: () {},
        scrollToMessage: (a, b) {},
        onDelete: () {},
        selectedMessageListIndex: BehaviorSubject.seeded([]),
      ),
    );
  }

  @override
  void initState() {
    createMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("theme")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<int>(
            stream: _idSubject,
            builder: (context, snapshot) {
              return StreamBuilder<int>(
                stream: settings.backgroundPatternIndex.stream,
                builder: (ctx, s) {
                  return Background(
                    id: snapshot.data ?? 0,
                  );
                },
              );
            },
          ),
          FluidContainerWidget(
            child: ListView(
              children: [
                Section(
                  children: [
                    Column(
                      children: [
                        SettingsTile(
                          title: _i18n.get("text_size"),
                          leading: const Icon(CupertinoIcons.textformat_size),
                          trailing: const SizedBox.shrink(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "A",
                                style: TextStyle(
                                  fontSize: DEFAULT_FONT_SIZE * MIN_FONT_SIZE,
                                ),
                              ),
                              Expanded(
                                child: StreamBuilder<double>(
                                  stream: settings.textScale.stream,
                                  builder: (context, snapshot) {
                                    return SliderTheme(
                                      data: const SliderThemeData(
                                        showValueIndicator:
                                            ShowValueIndicator.never,
                                      ),
                                      child: Slider(
                                        divisions: 4,
                                        value: snapshot.data ?? 1,
                                        max: MAX_FONT_SIZE,
                                        min: MIN_FONT_SIZE,
                                        label: (snapshot.data ?? 1).toString(),
                                        onChanged: (value) {
                                          settings.textScale.set(value);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Text(
                                "A",
                                style: TextStyle(
                                  fontSize: DEFAULT_FONT_SIZE * MAX_FONT_SIZE,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SettingsTile.switchTile(
                      title: _i18n.get("text_justification"),
                      leading: const Icon(CupertinoIcons.text_append),
                      switchValue: settings.showTextsJustified.value,
                      onToggle: ({required newValue}) {
                        _analyticsService.sendLogEvent(
                          "toggleShowTextsJustified",
                        );
                        setState(
                          () => settings.showTextsJustified.toggleValue(),
                        );
                      },
                    ),
                    if (!isWeb)
                      SettingsTile.switchTile(
                        title: _i18n.get("show_link_preview"),
                        leading: const Icon(CupertinoIcons.link),
                        switchValue: settings.showLinkPreview.value,
                        enabled: settings.showLinkPreview.enabled,
                        onToggle: ({required newValue}) {
                          _analyticsService.sendLogEvent(
                            "toggleShowLinkPreview",
                          );
                          setState(() {
                            settings.showLinkPreview.toggleValue();
                          });
                        },
                      ),
                    SettingsTile.switchTile(
                      title: _i18n["show_animated_emojis"],
                      leading: const Icon(Icons.emoji_emotions_outlined),
                      releaseState: ReleaseState.NEW,
                      switchValue: settings.showAnimatedEmoji.value,
                      enabled: settings.showAnimatedEmoji.enabled,
                      onToggle: ({required newValue}) {
                        setState(
                          () => settings.showAnimatedEmoji.toggleValue(),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(p16),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                            borderRadius: mainBorder,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: p4,
                            vertical: p4,
                          ),
                          child: Column(
                            children: [
                              ...createFakeMessages(),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          bottom: p12,
                          left: p8 * 2,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: FloatingActionButton(
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onTertiary,
                              onPressed: () =>
                                  _idSubject.add(_idSubject.value + 1),
                              child: const Icon(Icons.rotate_right),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Section(
                  title: _i18n.get("advanced_settings"),
                  children: [
                    Column(
                      children: [
                        SettingsTile(
                          title: _i18n.get("main_color"),
                          leading: const Icon(CupertinoIcons.color_filter),
                          trailing: const SizedBox.shrink(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0; i < palettes.length; i++)
                                  color(palettes[i], i)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SettingsTile.switchTile(
                      title: _i18n["show_background"],
                      leading: const Icon(Icons.image_not_supported_outlined),
                      switchValue: settings.showRoomBackground.value,
                      releaseState: ReleaseState.NEW,
                      enabled: settings.showRoomBackground.enabled,
                      onToggle: ({required newValue}) {
                        setState(
                          () => settings.showRoomBackground.toggleValue(),
                        );
                      },
                    ),
                    if (settings.showRoomBackground.value)
                      StreamBuilder<int>(
                        stream: settings.backgroundPatternIndex.stream,
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              SettingsTile(
                                title: _i18n.get("pattern"),
                                leading: const Icon(CupertinoIcons.photo),
                                trailing: const SizedBox.shrink(),
                              ),
                              Row(
                                children: [
                                  if (isDesktopDevice)
                                    IconButton(
                                      onPressed: () => _controller.animateTo(
                                        _controller.position.pixels - 200,
                                        duration: AnimationSettings.superSlow,
                                        curve: Curves.ease,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                      ),
                                    ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _controller,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (var i = 0;
                                              i < patterns.length;
                                              i++)
                                            pattern(patterns[i], i),
                                          pattern(null, patterns.length)
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isDesktopDevice)
                                    IconButton(
                                      onPressed: () => _controller.animateTo(
                                        _controller.position.pixels + 200,
                                        duration: AnimationSettings.superSlow,
                                        curve: Curves.ease,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
                                    ),
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    SettingsTile.switchTile(
                      title: _i18n["repeat_animated_emojis"],
                      leading: const Icon(Icons.animation),
                      releaseState: ReleaseState.NEW,
                      switchValue: settings.repeatAnimatedEmoji.value,
                      enabled: settings.repeatAnimatedEmoji.enabled,
                      onToggle: ({required newValue}) {
                        setState(
                          () => settings.repeatAnimatedEmoji.toggleValue(),
                        );
                      },
                    ),
                    SettingsTile.switchTile(
                      title: _i18n["show_animations_with_higher_frame_rates"],
                      leading: const Icon(CupertinoIcons.flame),
                      releaseState: ReleaseState.NEW,
                      switchValue: settings.showWsWithHighFrameRate.value,
                      enabled: settings.showWsWithHighFrameRate.enabled,
                      onToggle: ({required newValue}) {
                        setState(
                          () => settings.showWsWithHighFrameRate.toggleValue(),
                        );
                      },
                    ),
                    SettingsTile.switchTile(
                      title: _i18n.get("colorful_messages"),
                      leading: const Icon(CupertinoIcons.paintbrush),
                      switchValue: settings.showColorfulMessages.value,
                      onToggle: ({required newValue}) {
                        _analyticsService.sendLogEvent(
                          "themeColorfulMessageToggle",
                        );
                        setState(() {
                          settings.showColorfulMessages.toggleValue();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildThemeSelection(),
                    ),
                    SettingsTile.switchTile(
                      title: _i18n.get("play_in_chat_sounds"),
                      leading: const Icon(CupertinoIcons.volume_off),
                      switchValue: settings.playInChatSounds.value,
                      onToggle: ({required newValue}) {
                        _analyticsService.sendLogEvent(
                          "togglePlayInChatSounds",
                        );
                        setState(() {
                          settings.playInChatSounds.toggleValue();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget color(Color color, int index) {
    final isSelected = settings.themeColorIndex.value == index;
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          settings.themeColorIndex.set(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              AnimatedContainer(
                duration: AnimationSettings.standard,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BackgroundPalettes[index],
                ),
                width: 15,
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pattern(String? pattern, int index) {
    final isSelected = settings.backgroundPatternIndex.value == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => settings.backgroundPatternIndex.set(index),
        child: AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          margin:
              isSelected ? const EdgeInsets.all(6) : const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: secondaryBorder,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  )
                : Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
          ),
          duration: AnimationSettings.standard,
          child: SizedBox(
            width: 80,
            height: 100,
            child: pattern == null
                ? Center(
                    child: Text(
                      _i18n.get("no_pattern"),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      Positioned(
                        top: 0,
                        child: Image(
                          width: 200,
                          image: AssetImage("assets/backgrounds/$pattern.webp"),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          fit: BoxFit.fill,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelection() {
    final colorPalette = settings.corePalette;
    return Column(
      children: [
        SettingsTile(
          title: _i18n.get("select_theme"),
          leading: const Icon(CupertinoIcons.circle_lefthalf_fill),
          trailing: const SizedBox.shrink(),
        ),
        Wrap(
          children: [
            _buildThemeSelectionItem(
              text: _i18n.get("dark_mode"),
              selectedBorderColor: Color(colorPalette.primary.get(60)),
              onTap: () {
                setState(() {
                  settings.isAutoNightModeEnable.set(false);
                  settings.themeIsDark.toggleValue();
                });
              },
              child: _darkThemeSelectionItemBackground(colorPalette),
              isSelected: settings.themeIsDark.value &&
                  !settings.isAutoNightModeEnable.value,
            ),
            const SizedBox(
              width: 8,
            ),
            _buildThemeSelectionItem(
              text: _i18n.get("light_mode"),
              selectedBorderColor: Color(colorPalette.primary.get(60)),
              onTap: () {
                setState(() {
                  settings.isAutoNightModeEnable.set(false);
                  settings.themeIsDark.set(false);
                });
              },
              child: _lightThemeSelectionItemBackground(colorPalette),
              isSelected: !settings.themeIsDark.value &&
                  !settings.isAutoNightModeEnable.value,
            ),
            const SizedBox(
              width: 8,
            ),
            _buildThemeSelectionItem(
              text: _i18n.get("os_default"),
              selectedBorderColor: Color(colorPalette.primary.get(60)),
              onTap: () {
                setState(() => settings.isAutoNightModeEnable.set(true));
              },
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: SizedBox(
                      width: 60,
                      height: 85,
                      child: _lightThemeSelectionItemBackground(
                        colorPalette,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 15,
                    child: SizedBox(
                      width: 60,
                      height: 85,
                      child: _darkThemeSelectionItemBackground(
                        colorPalette,
                      ),
                    ),
                  ),
                ],
              ),
              isSelected: settings.isAutoNightModeEnable.value,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeSelectionItem({
    required Widget child,
    required String text,
    required Color selectedBorderColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: tertiaryBorder,
                      border: Border.all(
                        color: selectedBorderColor,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: child,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _lightThemeSelectionItemBackground(CorePalette colorPalette) {
    return _buildThemeSelectionItemBackground(
      patternColor: Color(colorPalette.primary.get(66)).withOpacity(0.5),
      backGroundColor: Color(colorPalette.primary.get(88)),
      box1Color: Color(colorPalette.primary.get(92)),
      box2Color: Colors.white,
      iconColor: Color(colorPalette.primary.get(50)),
      icon: CupertinoIcons.sun_max_fill,
    );
  }

  Widget _darkThemeSelectionItemBackground(CorePalette colorPalette) {
    return _buildThemeSelectionItemBackground(
      patternColor: Color(colorPalette.primary.get(70)).withOpacity(0.5),
      backGroundColor: Colors.black,
      box1Color: Color(colorPalette.primary.get(50)),
      box2Color: Color(colorPalette.neutral.get(30)),
      iconColor: Color(colorPalette.primary.get(90)),
      icon: CupertinoIcons.moon_fill,
    );
  }

  Widget _buildThemeSelectionItemBackground({
    required Color patternColor,
    required Color backGroundColor,
    required Color box1Color,
    required Color box2Color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: tertiaryBorder,
        color: backGroundColor,
      ),
      child: Stack(
        children: [
          if (patterns.length < settings.backgroundPatternIndex.value)
            Positioned(
              top: 0,
              child: Image(
                width: 260,
                image: AssetImage(
                  "assets/backgrounds/${patterns[settings.backgroundPatternIndex.value]}.webp",
                ),
                color: patternColor,
                fit: BoxFit.fill,
                repeat: ImageRepeat.repeat,
              ),
            ),
          Positioned(
            top: 10,
            right: 5,
            child: Container(
              width: 35,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: tertiaryBorder,
                color: box1Color,
                boxShadow: DEFAULT_BOX_SHADOWS,
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 5,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: tertiaryBorder,
                color: box2Color,
                boxShadow: DEFAULT_BOX_SHADOWS,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
