import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
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

  const ShareInputFile({required this.inputSharedFilePath, Key? key})
      : super(key: key);

  @override
  State<ShareInputFile> createState() => _ShareInputFileState();
}

class _ShareInputFileState extends State<ShareInputFile> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final _selectedRooms = [];
  final TextEditingController _textEditingController = TextEditingController();

  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

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
          Column(
            children: [
              SearchBox(
                onChange: _queryTermDebouncedSubject.add,
                onCancel: () => _queryTermDebouncedSubject.add(""),
              ),
              StreamBuilder<String>(
                stream: _queryTermDebouncedSubject.stream,
                builder: (context, query) {
                  return Expanded(
                    child: FutureBuilder<List<Uid>>(
                      future: query.data != null && query.data!.isNotEmpty
                          ? _roomRepo.searchInRoomAndContacts(query.data!)
                          : _roomRepo.getAllRooms(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (ctx, index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (_selectedRooms.contains(
                                      snapshot.data![index].asString(),)) {
                                    _selectedRooms.remove(
                                        snapshot.data![index].asString(),);
                                  } else {
                                    _selectedRooms
                                        .add(snapshot.data![index].asString());
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  color: _selectedRooms.contains(
                                    snapshot.data![index].asString(),
                                  )
                                      ? theme.hoverColor
                                      : theme.backgroundColor,
                                  child: ShareChatItem(
                                    uid: snapshot.data![index],
                                    selected: _selectedRooms.contains(
                                        snapshot.data![index].asString(),),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          if (_selectedRooms.isNotEmpty)
            buildInputCaption(
              i18n: _i18n,
              insertCaption: _insertCaption,
              context: context,
              captionEditingController: _textEditingController,
              count: _selectedRooms.length,
              send: () {
                for (final String roomUid in _selectedRooms) {
                  _messageRepo.sendMultipleFilesMessages(
                    roomUid.asUid(),
                    widget.inputSharedFilePath
                        .map((e) => File(e, e.split(".").last))
                        .toList(),
                    caption: _textEditingController.text,
                  );
                }
                if (_selectedRooms.length == 1) {
                  _routingServices.openRoom(_selectedRooms.first,popAllBeforePush: true);
                } else {
                  _routingServices.pop();
                }
              },
            )
        ],
      ),
    );
  }
}
