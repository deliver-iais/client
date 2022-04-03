import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SelectionToForwardPage extends StatefulWidget {
  final List<Message>? forwardedMessages;
  final List<Media>? medias;
  final proto.ShareUid? shareUid;

  const SelectionToForwardPage({
    Key? key,
    this.forwardedMessages,
    this.medias,
    this.shareUid,
  }) : super(key: key);

  @override
  _SelectionToForwardPageState createState() => _SelectionToForwardPageState();
}

class _SelectionToForwardPageState extends State<SelectionToForwardPage> {
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  void dispose() {
    _queryTermDebouncedSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ForwardAppbar(),
      ),
      body: Column(
        children: <Widget>[
          SearchBox(
            onChange: _queryTermDebouncedSubject.add,
            onCancel: () => _queryTermDebouncedSubject.add(""),
          ),
          Expanded(
            child: StreamBuilder<String>(
              stream: _queryTermDebouncedSubject.stream,
              builder: (context, snapshot) {
                return FutureBuilder<List<Uid>>(
                  future: snapshot.hasData && snapshot.data!.isNotEmpty
                      ? _roomRepo.searchInRoomAndContacts(snapshot.data!)
                      : _roomRepo.getAllRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return Container(
                        child: buildListView(snapshot.data!),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _send(Uid uid) {
    _routingService.openRoom(
      uid.asString(),
      forwardedMessages: widget.forwardedMessages ?? [],
      popAllBeforePush: true,
      forwardedMedia: widget.medias ?? [],
      shareUid: widget.shareUid,
    );
  }

  ListView buildListView(List<Uid> uids) {
    return ListView.builder(
      itemCount: uids.length,
      itemBuilder: (ctx, index) {
        return ChatItemToForward(
          uid: uids[index],
          send: _send,
        );
      },
    );
  }
}
