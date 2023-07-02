import 'dart:async';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/room/widgets/search_message_room/build_member_widget.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/room_message_result.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SearchMessageInRoomWidget extends StatefulWidget {
  final Uid? uid;

  const SearchMessageInRoomWidget({
    super.key,
    this.uid,
  });

  @override
  SearchMessageInRoomWidgetState createState() =>
      SearchMessageInRoomWidgetState();
}

class SearchMessageInRoomWidgetState extends State<SearchMessageInRoomWidget> {
  late SearchMessageService searchMessageService;
  final TextEditingController _localController = TextEditingController();
  final StreamController<int> _streamController = StreamController<int>();
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  static final _i18n = GetIt.I.get<I18N>();

  @override
  void dispose() {
    _localController.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    _searchMessageService.inSearchMessageMode.add(widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurredPreferredSizedWidget(
        child: Row(
          children: [
            Expanded(
              child: SearchBox(
                onChange: (str) => _searchMessageService.text.add(str),
                onCancel: () => _searchMessageService.text.add(null),
              ),
            ),
            if (!isLarge(context)) ...[
              const SizedBox(
                width: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (_searchMessageService.searchResult.hasValue &&
                        _searchMessageService.searchResult.value == true) {
                      _searchMessageService.searchResult.add(false);
                    } else {
                      _searchMessageService.inSearchMessageMode.add(null);
                      _searchMessageService.text.add(null);
                      _searchMessageService.foundMessageId.add(-1);
                    }
                  },
                  child: Text(
                    _i18n.get("cancel"),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
      body: Column(
        children: [
          if (isLarge(context)) ...[
            const SizedBox(
              height: 1,
            ),
            Expanded(
              child: StreamBuilder<int>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  return _buildMessageList();
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textDirection: _i18n.defaultTextDirection,
            _i18n.get("search_messages_in"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        BuildMemberWidget(uid: widget.uid!),
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textDirection: _i18n.defaultTextDirection,
            _i18n.get("search_for_messages"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        RoomMessageResult(
          uid: widget.uid!,
        ),
      ],
    );
  }
}
