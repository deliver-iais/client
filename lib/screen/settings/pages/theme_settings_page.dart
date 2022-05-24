import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

const fakeUser = "0:fake_user";

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  List<Message> messages = [];

  void createMessages() {
    final cUser = _authRepo.currentUserUid.asString();
    messages = [
      cm(1, cUser, fakeUser, "سلام"),
      cm(2, cUser, fakeUser, "امروز میخواستیم با بچه ها بریم فوتبال، میای ؟"),
      cm(3, fakeUser, cUser, "حتما، چه ساعتیه ؟!", replyId: 2),
      cm(4, cUser, fakeUser, "ایول\\n \\n ساعت ۹ شب، همونجای همیشگی. منتظرتیم"),
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
      roomUid: fakeUser,
    );
  }

  MessageReplyBrief? cfm(int id) {
    if (id <= 0) {
      return null;
    }

    final m = messages[id - 1];
    final text = m.json.toText().text;

    return MessageReplyBrief(
      roomUid: m.roomUid,
      id: id,
      time: m.time,
      from: m.from,
      to: m.to,
      text: text,
    );
  }

  BuildMessageBox buildMessageBox(int msgId) {
    final msg = messages[msgId - 1];
    final replyId = msg.replyToId;
    Message? bMsg;

    if (msgId > 1) {
      bMsg = messages[msgId - 2];
    }

    print(cfm(replyId));

    return BuildMessageBox(
      message: msg,
      messageReplyBrief: cfm(replyId),
      messageBefore: bMsg,
      roomId: fakeUser,
      lastSeenMessageId: 1,
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
          title: Text(_i18n.get("advanced_settings")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            decoration: const BoxDecoration(
              borderRadius: mainBorder,
            ),
            clipBehavior: Clip.hardEdge,
            child: ListView(
              children: [
                SizedBox(
                  height: 450,
                  child: Stack(
                    children: [
                      const Background(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const Spacer(),
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
                    height: 850,
                    decoration: const BoxDecoration(
                      borderRadius: mainBorder,
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
