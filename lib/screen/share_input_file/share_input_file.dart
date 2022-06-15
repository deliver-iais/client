import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/search_box_and_list_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/share_input_file/share_chat_item.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShareInputFile extends StatefulWidget {
  final List<String> inputSharedFilePath;
  final String inputShareText;

  const ShareInputFile({
    required this.inputSharedFilePath,
    required this.inputShareText,
    Key? key,
  }) : super(key: key);

  @override
  State<ShareInputFile> createState() => _ShareInputFileState();
}

class _ShareInputFileState extends State<ShareInputFile> {
  final _routingServices = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final _selectedRooms = <Uid>[];
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _selectedRooms.isEmpty
              ? _i18n.get("send_To")
              : "${_i18n.get("selected_chats")} : ${_selectedRooms.length}",
          style: Theme.of(context)
              .appBarTheme
              .titleTextStyle!
              .copyWith(fontSize: 20),
        ),
        leading: _routingServices.backButtonLeading(),
      ),
      body: Stack(
        children: <Widget>[
          SearchBoxAndListWidget(
            listWidget: buildSharedList,
            emptyWidget: const SizedBox.shrink(),
          ),
          if (_selectedRooms.isNotEmpty)
            if (widget.inputShareText.isNotEmpty)
              buildSend()
            else
              buildInputCaption(
                i18n: _i18n,
                insertCaption: _insertCaption,
                context: context,
                captionEditingController: _textEditingController,
                count: _selectedRooms.length,
                send: () {
                  for (final path in widget.inputSharedFilePath) {
                    _messageRepo.sendFileToChats(
                      _selectedRooms,
                      File(
                        path,
                        path.split(".").last,
                      ),
                      caption: widget.inputSharedFilePath.last == path
                          ? _textEditingController.text
                          : "",
                    );
                  }
                  pop();
                },
              )
        ],
      ),
    );
  }

  void pop() {
    if (_selectedRooms.length == 1) {
      _routingServices.openRoom(
        _selectedRooms.first.asString(),
        popAllBeforePush: true,
      );
    } else {
      _routingServices.pop();
    }
  }

  Widget buildSend() {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Material(
                  color: Theme.of(context).primaryColor, // button color
                  child: InkWell(
                    splashColor: theme.primaryColor, // inkwell color
                    child: const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.send,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      for (final roomUid in _selectedRooms) {
                        _messageRepo.sendTextMessage(
                          roomUid,
                          widget.inputShareText,
                        );
                      }
                      pop();
                    },
                  ),
                ),
              ),
            ),
            if (_selectedRooms.isNotEmpty)
              Positioned(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.backgroundColor, // border color
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2), // border width
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor, // inner circle color
                      ),
                      child: Center(
                        child: Text(
                          _selectedRooms.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ), // inner content
                    ),
                  ),
                ),
                top: 35.0,
                right: 0.0,
                left: 35,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSharedList(List<Uid> uidList) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: uidList.length,
      itemBuilder: (ctx, index) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_selectedRooms.contains(
              uidList[index],
            )) {
              _selectedRooms.remove(
                uidList[index],
              );
            } else {
              _selectedRooms.add(uidList[index]);
            }
            setState(() {});
          },
          child: Container(
            color: _selectedRooms.contains(
              uidList[index],
            )
                ? theme.hoverColor
                : theme.backgroundColor,
            child: ShareChatItem(
              uid: uidList[index],
              selected: _selectedRooms.contains(
                uidList[index],
              ),
            ),
          ),
        );
      },
    );
  }
}
