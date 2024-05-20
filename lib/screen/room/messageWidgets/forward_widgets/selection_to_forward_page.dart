import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver/screen/room/widgets/search_box_and_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../box/room.dart';

class SelectionToForwardPage extends StatefulWidget {
  final List<Message>? forwardedMessages;
  final List<Meta>? metas;
  final proto.ShareUid? shareUid;

  const SelectionToForwardPage({
    super.key,
    this.forwardedMessages,
    this.metas,
    this.shareUid,
  });

  @override
  SelectionToForwardPageState createState() => SelectionToForwardPageState();
}

class SelectionToForwardPageState extends State<SelectionToForwardPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  RxList<Uid> selected = <Uid>[].obs;

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: Obx(
        () => selected.isNotEmpty
            ? Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      for (final uid in selected) {
                        if (widget.forwardedMessages != null) {
                          _messageRepo.sendForwardedMessage(
                              uid, widget.forwardedMessages!);
                        } else if (widget.shareUid != null) {
                          _messageRepo.sendShareUidMessage(
                              uid, widget.shareUid!);
                        } else {
                          _messageRepo.sendForwardedMetaMessage(
                            uid,
                            widget.metas!,
                          );
                        }
                      }
                      _routingService.pop();
                    },
                    child: const Icon(CupertinoIcons.location),
                  ),
                  Positioned(
                    right: -1,
                    top: 1,
                    child: Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: theme.dividerColor),
                        //     borderRadius: BorderRadius.circular(100)
                        // ),
                        child: Obx(() => Text(
                              selected.length.toString(),
                            ))),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
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

  void _onTap(Uid uid) {
    if (selected.isNotEmpty) {
      if (selected.contains(uid)) {
        selected.remove(uid);
      } else {
        selected.add(uid);
      }
    } else {
      _routingService.openRoom(
        uid,
        forwardedMessages: widget.forwardedMessages ?? [],
        popAllBeforePush: true,
        forwardedMeta: widget.metas ?? [],
        shareUid: widget.shareUid,
      );
    }
  }

  Widget buildListView(List<Room> uidList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: uidList.length,
      itemBuilder: (ctx, index) {
        return Obx(() {
          final isSelect = selected.contains(uidList[index].uid);
          return Container(
            color: isSelect ? theme.dividerColor : null,
            child: ChatItemToForward(
              onLongPressed: (uid) {
                selected.add(uid);
              },
              room: uidList[index],
              isSelected: isSelect,
              onTap: _onTap,
            ),
          );
        });
      },
    );
  }
}
