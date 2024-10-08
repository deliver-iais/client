import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
import 'package:deliver/screen/navigation_center/search/room_information_widget.dart';
import 'package:deliver/theme/theme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchResultWidget extends StatefulWidget {
  final SearchController searchBoxController;

  const SearchResultWidget({super.key, required this.searchBoxController});

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _scrollController = ScrollController();
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  void initState() {
    widget.searchBoxController.addListener(() {
      if (widget.searchBoxController.text.length > 2) {
        _queryTermDebouncedSubject.add(widget.searchBoxController.text);
      }
    });
    super.initState();
  }

  final _localHasResult = true.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<UidIdName>>(
          stream: _roomRepo.searchInRooms(widget.searchBoxController.text),
          builder: (c, snaps) {
            // _localHasResult.value =
            //     snaps.hasData && snaps.data != null && snaps.data!.isNotEmpty;
            if (snaps.connectionState == ConnectionState.waiting &&
                (!snaps.hasData || snaps.data!.isEmpty)) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(34.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return searchResultWidget(snaps.data!);
          },
        ),
        StreamBuilder<String>(
          stream: _queryTermDebouncedSubject
              .debounceTime(const Duration(milliseconds: 250)),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              return FutureBuilder<List<UidIdName>>(
                future: globalSearchUser(snapshot.data!),
                builder: (c, snaps) {
                  if (!snaps.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final global = snaps.data!;
                  if (global.isEmpty) {
                    return Obx(
                      () => _localHasResult.value
                          ? const SizedBox.shrink()
                          : const NoResultWidget(),
                    );
                  }
                  return Column(
                    children: [
                      if (global.isNotEmpty) ...[
                        buildTitle(_i18n.get("global_search")),
                        searchResultWidget(global)
                      ]
                    ],
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        )
      ],
    );
  }

  Widget buildTitle(String title) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsetsDirectional.only(bottom: 4),
      width: double.infinity,
      color: theme.dividerColor.withAlpha(40),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: getFadeTextStyle(context),
      ),
    );
  }

  Future<List<UidIdName>> globalSearchUser(String query) =>
      _contactRepo.searchUser(query);

  Widget searchResultWidget(List<UidIdName> uidList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        itemCount: uidList.length,
        itemBuilder: (c, index) => RoomInformationWidget(
          uid: uidList[index].uid,
          width: 200,
          flex: 0,
          name: uidList[index].name,
          id: uidList[index].id,
        ),
      ),
    );
  }
}
