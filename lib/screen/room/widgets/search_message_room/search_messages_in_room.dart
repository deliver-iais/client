import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/room/widgets/search_message_room/build_member_widget.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/room_message_result_in_page.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessageInRoomWidget extends StatefulWidget {
  const SearchMessageInRoomWidget({
    super.key,
  });

  @override
  SearchMessageInRoomWidgetState createState() =>
      SearchMessageInRoomWidgetState();
}

class SearchMessageInRoomWidgetState extends State<SearchMessageInRoomWidget> {
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  static final _i18n = GetIt.I.get<I18N>();

  final _keyBord = BehaviorSubject.seeded("");

  @override
  void initState() {
    _keyBord.debounceTime(const Duration(milliseconds: 250)).listen((event) {
      _searchMessageService.text.add(event);
    });
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
                onChange: (str) => {_keyBord.add(str)},
                onCancel: () => {
                  _searchMessageService.text.add(null),
                  _searchMessageService.currentSelectedMessageId.add(-1)
                },
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
                    if (_searchMessageService
                            .openSearchResultPageOnFooter.hasValue &&
                        _searchMessageService
                                .openSearchResultPageOnFooter.value ==
                            true) {
                      _searchMessageService.openSearchResultPageOnFooter
                          .add(false);
                    } else {
                      _searchMessageService.closeSearch();
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
            Expanded(child: _buildMessageList()),
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
        BuildRoomWidget(uid: _searchMessageService.getUid()!),
        const Divider(),
        // Container(
        //   width: MediaQuery.of(context).size.width,
        //   color: Theme.of(context).colorScheme.onInverseSurface,
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     textDirection: _i18n.defaultTextDirection,
        //     _i18n.get("search_for_messages"),
        //     style: const TextStyle(fontWeight: FontWeight.bold),
        //   ),
        // ),
        RoomMessageResultInPage(
          uid: _searchMessageService.getUid()!,
        ),
      ],
    );
  }
}
