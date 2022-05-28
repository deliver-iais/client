import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../../../shared/widgets/settings_ui/box_ui.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  static final _uxService = GetIt.I.get<UxService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  List<Message> messages = [];

  void createMessages() {
    final cUser = _authRepo.currentUserUid.asString();
    messages = [
      cm(1, cUser, FAKE_USER_UID.asString(), "سلام"),
      cm(
        2,
        cUser,
        FAKE_USER_UID.asString(),
        "امروز میخواستیم با بچه ها بریم فوتبال، میای ؟",
      ),
      cm(3, FAKE_USER_UID.asString(), cUser, "حتما، چه ساعتیه ؟!", replyId: 2),
      cm(
        4,
        cUser,
        FAKE_USER_UID.asString(),
        "ایول\\n \\n ساعت ۹ شب، همونجای همیشگی. منتظرتیم",
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
      onEdit: () {},
      onPin: () {},
      onUnPin: () {},
      onReply: () {},
      addForwardMessage: () {},
      scrollToMessage: (a, b) {},
      onDelete: () {},
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
      body: FluidContainerWidget(
        child: ListView(
          children: [
            SizedBox(
              height: 480,
              child: Stack(
                children: [
                  const Background(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        ...createFakeMessages(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -(mainBorder.topLeft.x)),
              child: Container(
                padding: const EdgeInsets.only(bottom: 12, top: 4),
                decoration: BoxDecoration(
                  borderRadius: mainBorder,
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  children: [
                    Section(
                      title: _i18n.get("theme"),
                      children: [
                        SettingsTile.switchTile(
                          title: _i18n.get("dark_mode"),
                          leading: const Icon(CupertinoIcons.moon),
                          switchValue: _uxService.themeIsDark,
                          onToggle: (value) {
                            setState(() {
                              _uxService.toggleThemeLightingMode();
                            });
                          },
                        ),
                        SettingsTile.switchTile(
                          title: _i18n.get("auto_night_mode"),
                          leading:
                              const Icon(CupertinoIcons.circle_lefthalf_fill),
                          switchValue: _uxService.isAutoNightModeEnable,
                          onToggle: (value) {
                            setState(() {
                              _uxService.toggleIsAutoNightMode();
                            });
                          },
                        ),
                      ],
                    ),
                    Section(
                      title: _i18n.get("advanced_settings"),
                      children: [
                        SettingsTile(
                          title: "Main Color",
                          leading: const Icon(CupertinoIcons.color_filter),
                          trailing: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                for (var i = 0; i < palettes.length; i++)
                                  color(palettes[i], i)
                              ],
                            ),
                          ),
                        ),
                        SettingsTile.switchTile(
                          title: "Colorful Messages",
                          leading: const Icon(CupertinoIcons.paintbrush),
                          switchValue: _uxService.showColorful,
                          onToggle: (value) {
                            setState(() {
                              _uxService.toggleShowColorful();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget color(Color color, int index) {
    final isSelected = _uxService.themeIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _uxService.selectTheme(index);
        },
        child: AnimatedContainer(
          duration: ANIMATION_DURATION * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: ANIMATION_DURATION * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
