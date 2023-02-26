import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
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
  static final _uxService = GetIt.I.get<UxService>();
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
      cm(3, FAKE_USER_UID.asString(), cUser, "حتما، چه ساعتیه ؟!", replyId: 2),
      cm(
        4,
        cUser,
        FAKE_USER_UID.asString(),
        "ایول\\n \\n ساعت ۹ شب، ورزشگاه. منتظرتیم",
        replyId: 3,
      ),
    ];
  }

  List<Widget> createFakeMessages() {
    return [
      buildMessageBox(1),
      buildMessageBox(2),
      buildMessageBox(3),
      buildMessageBox(4),
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
      from: from,
      replyToId: replyId ?? 0,
      to: to,
      time: id,
      isHidden: false,
      json: '{"1":"$text"}',
      packetId: '',
      roomUid: FAKE_USER_UID.asString(),
    );
  }

  MessageBrief? cfm(int id) {
    if (id <= 0) {
      return null;
    }

    final m = messages[id - 1];
    final text = m.json.toText().text;

    return MessageBrief(
      roomUid: m.roomUid,
      packetId: m.packetId,
      id: m.id ?? 0,
      time: m.time,
      from: m.from,
      to: m.to,
      text: text,
      type: m.type,
    );
  }

  BuildMessageBox buildMessageBox(int msgId) {
    final msg = messages[msgId - 1];
    final replyId = msg.replyToId;
    Message? bMsg;

    if (msgId > 1) {
      bMsg = messages[msgId - 2];
    }

    return BuildMessageBox(
      message: msg,
      messageReplyBrief: cfm(replyId),
      messageBefore: bMsg,
      roomId: FAKE_USER_UID.asString(),
      lastSeenMessageId: messages.length - 1,
      pinMessages: const [],
      selectMultiMessageSubject: BehaviorSubject.seeded(false),
      hasPermissionInGroup: false,
      hasPermissionInChannel: BehaviorSubject.seeded(false),
      menuDisabled: true,
      onEdit: () {},
      onPin: () {},
      onUnPin: () {},
      onReply: () {},
      addForwardMessage: () {},
      scrollToMessage: (a, b) {},
      onDelete: () {},
      selectedMessageListIndex: BehaviorSubject(),
    );
  }

  @override
  Widget build(BuildContext context) {
    createMessages();

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
                stream: _uxService.patternIndexStream,
                builder: (ctx, s) {
                  return Background(
                    id: snapshot.data ?? 0,
                  );
                },
              );
            },
          ),
          FluidContainerWidget(
            // showStandardContainer: true,
            // backGroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: Directionality(
              textDirection: _i18n.defaultTextDirection,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
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
                                  child: Directionality(
                                    textDirection: _i18n.defaultTextDirection,
                                    child: StreamBuilder<double>(
                                      stream: _uxService.sliderValueStream,
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
                                            label:
                                                (snapshot.data ?? 1).toString(),
                                            onChanged: (value) {
                                              _uxService.selectTextSize(value);
                                            },
                                          ),
                                        );
                                      },
                                    ),
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
                        switchValue: _uxService.showTextsJustified,
                        onToggle: (value) {
                          _analyticsService.sendLogEvent(
                            "themeColorfulMessageToggle",
                          );
                          setState(() {
                            _uxService.toggleShowTextsJustified();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  width: 4,
                                ),
                                borderRadius: mainBorder,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 8.0
                              ),
                              child: Column(
                                children: [
                                  ...createFakeMessages(),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            bottom: 16,
                            left: 40,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: FloatingActionButton(
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
                  Container(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Column(
                      children: [
                        Section(
                          title: _i18n.get("advanced_settings"),
                          children: [
                            Column(
                              children: [
                                SettingsTile(
                                  title: _i18n.get("main_color"),
                                  leading:
                                      const Icon(CupertinoIcons.color_filter),
                                  trailing: const SizedBox.shrink(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (var i = 0;
                                            i < palettes.length;
                                            i++)
                                          color(palettes[i], i)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<int>(
                              stream: _uxService.patternIndexStream,
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
                                        if (isDesktop)
                                          IconButton(
                                            onPressed: () =>
                                                _controller.animateTo(
                                              _controller.position.pixels - 200,
                                              duration:
                                                  SUPER_SLOW_ANIMATION_DURATION,
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
                                        if (isDesktop)
                                          IconButton(
                                            onPressed: () =>
                                                _controller.animateTo(
                                              _controller.position.pixels + 200,
                                              duration:
                                                  SUPER_SLOW_ANIMATION_DURATION,
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
                              title: _i18n.get("colorful_messages"),
                              leading: const Icon(CupertinoIcons.paintbrush),
                              switchValue: _uxService.showColorful,
                              onToggle: (value) {
                                _analyticsService.sendLogEvent(
                                  "themeColorfulMessageToggle",
                                );
                                setState(() {
                                  _uxService.toggleShowColorful();
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildThemeSelection(),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget color(Color color, int index) {
    final isSelected = _uxService.themeIndex == index;
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _uxService.selectTheme(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              AnimatedContainer(
                duration: MOTION_STANDARD_ANIMATION_DURATION,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.primaryColor,
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
    final isSelected = _uxService.patternIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _uxService.selectPattern(index),
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
          duration: MOTION_STANDARD_ANIMATION_DURATION,
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
    final colorPalette = CorePalette.of(palettes[_uxService.themeIndex].value);
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
                  _uxService.toggleThemeToDarkMode(
                    forceToDisableAutoNightMode: true,
                  );
                });
              },
              child: _darkThemeSelectionItemBackground(colorPalette),
              isSelected:
                  _uxService.themeIsDark && !_uxService.isAutoNightModeEnable,
            ),
            const SizedBox(
              width: 8,
            ),
            _buildThemeSelectionItem(
              text: _i18n.get("light_mode"),
              selectedBorderColor: Color(colorPalette.primary.get(60)),
              onTap: () {
                setState(() {
                  _uxService.toggleThemeToLightMode(
                    forceToDisableAutoNightMode: true,
                  );
                });
              },
              child: _lightThemeSelectionItemBackground(colorPalette),
              isSelected:
                  !_uxService.themeIsDark && !_uxService.isAutoNightModeEnable,
            ),
            const SizedBox(
              width: 8,
            ),
            _buildThemeSelectionItem(
              text: _i18n.get("os_default"),
              selectedBorderColor: Color(colorPalette.primary.get(60)),
              onTap: () {
                setState(() {
                  _uxService.enableAutoNightMode();
                });
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
              isSelected: _uxService.isAutoNightModeEnable,
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
          if (patterns.length < _uxService.patternIndex)
            Positioned(
              top: 0,
              child: Image(
                width: 260,
                image: AssetImage(
                  "assets/backgrounds/${patterns[_uxService.patternIndex]}.webp",
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
