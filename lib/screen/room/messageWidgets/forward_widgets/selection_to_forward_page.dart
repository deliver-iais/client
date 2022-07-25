import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver/screen/room/widgets/search_box_and_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectionToForwardPage extends StatefulWidget {
  final List<Message>? forwardedMessages;
  final List<Media>? medias;
  final proto.ShareUid? shareUid;

  const SelectionToForwardPage({
    super.key,
    this.forwardedMessages,
    this.medias,
    this.shareUid,
  });

  @override
  SelectionToForwardPageState createState() => SelectionToForwardPageState();
}

class SelectionToForwardPageState extends State<SelectionToForwardPage> {
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ForwardAppbar(),
      ),
      body: SearchBoxAndListWidget(
        listWidget: buildListView,
        emptyWidget: const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blue,
          ),
        ),
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

  Widget buildListView(List<Uid> uidList) {
    return ListView.builder(
      itemCount: uidList.length,
      itemBuilder: (ctx, index) {
        return ChatItemToForward(
          uid: uidList[index],
          send: _send,
        );
      },
    );
  }
}
