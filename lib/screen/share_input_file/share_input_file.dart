import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/search_box_and_list_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/screen/share_input_file/share_chat_item.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareInputFile extends StatefulWidget {
  final List<String> inputSharedFilePath;
  final String inputShareText;

  const ShareInputFile({
    super.key,
    required this.inputSharedFilePath,
    required this.inputShareText,
  });

  @override
  State<ShareInputFile> createState() => _ShareInputFileState();
}

class _ShareInputFileState extends State<ShareInputFile> {
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  final _selectedRooms = <Uid>[];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          _selectedRooms.isEmpty
              ? _i18n.get("send_To")
              : "${_i18n.get("selected_chats")} : ${_selectedRooms.length}",
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
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: ShareBoxInputCaption(
                  count: _selectedRooms.length,
                  onSend: (caption) {
                    for (final path in widget.inputSharedFilePath) {
                      _messageRepo.sendFileToChats(
                        _selectedRooms,
                        pathToFileModel(path),
                        caption: widget.inputSharedFilePath.last == path
                            ? caption
                            : "",
                      );
                    }
                    pop();
                  },
                ),
              )
        ],
      ),
    );
  }

  void pop() {
    if (_selectedRooms.length == 1) {
      _routingServices.openRoom(
        _selectedRooms.first,
        scrollToLastMessage: true,
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
        padding: const EdgeInsetsDirectional.only(end: 20),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Material(
                  color: theme.colorScheme.primary, // button color
                  child: InkWell(
                    splashColor: theme.colorScheme.primary, // inkwell color
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
                top: 35.0,
                right: 0.0,
                left: 35,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background, // border color
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(2),
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
                : theme.colorScheme.background,
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
