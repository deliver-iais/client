import 'package:deliver/box/message.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';

import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectionToForwardPage extends StatefulWidget {
  final List<Message> forwardedMessages;
  final proto.ShareUid shareUid;

  const SelectionToForwardPage({Key key, this.forwardedMessages, this.shareUid})
      : super(key: key);

  @override
  _SelectionToForwardPageState createState() => _SelectionToForwardPageState();
}

class _SelectionToForwardPageState extends State<SelectionToForwardPage> {
  bool _searchMode = false;
  String _query = "";

  @override
  Widget build(BuildContext context) {
    var _roomRepo = GetIt.I.get<RoomRepo>();

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ForwardAppbar(),
      ),
      body: Column(
        children: <Widget>[
          SearchBox(
            onChange: (str) {
              if (str.isNotEmpty) {
                setState(() {
                  _searchMode = true;
                  _query = str;
                });
              } else {
                setState(() {
                  _searchMode = false;
                });
              }
            },
            onCancel: (){
              setState(() {
                _searchMode = false;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Uid>>(
              future: _searchMode
                  ? _roomRepo.searchInRoomAndContacts(_query)
                  : _roomRepo.getAllRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data.length > 0) {
                  return Container(
                    child: buildListView(snapshot.data),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView buildListView(List<Uid> uids) {
    return ListView.builder(
      itemCount: uids.length,
      itemBuilder: (BuildContext ctx, int index) {
        return ChatItemToForward(
          uid: uids[index],
          forwardedMessages: widget.forwardedMessages,
          shareUid: widget.shareUid,
        );
      },
    );
  }
}
