import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
import 'package:deliver/screen/navigation_center/search/room_information_widget.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchResultWidget extends StatefulWidget {
  final TextEditingController searchBoxController;

  const SearchResultWidget({Key? key, required this.searchBoxController})
      : super(key: key);

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  void initState() {
    widget.searchBoxController.addListener(() {
      _queryTermDebouncedSubject.add(widget.searchBoxController.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Uid>>>(
      future: searchUidList(widget.searchBoxController.text),
      builder: (c, snaps) {
        if (!snaps.hasData || snaps.data!.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final contacts = snaps.data![0];
        final roomAndContacts = snaps.data![1];
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (contacts.isNotEmpty) ...[
                  buildTitle(_i18n.get("contacts")),
                  ...searchResultWidget(contacts),
                ],
                if (roomAndContacts.isNotEmpty) ...[
                  buildTitle(_i18n.get("local_search")),
                  ...searchResultWidget(roomAndContacts)
                ],
                StreamBuilder<String>(
                  stream: _queryTermDebouncedSubject
                      .debounceTime(const Duration(milliseconds: 250)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return FutureBuilder<List<Uid>>(
                        future: globalSearchUser(snapshot.data!),
                        builder: (c, snaps) {
                          if (!snaps.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            );
                          }
                          final global = snaps.data!;
                          if (global.isEmpty &&
                              roomAndContacts.isEmpty &&
                              contacts.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: const NoResultWidget(),
                            );
                          }
                          return Column(
                            children: [
                              if (global.isNotEmpty) ...[
                                buildTitle(_i18n.get("global_search")),
                                ...searchResultWidget(global)
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
            ),
          ),
        );
      },
    );
  }

  Widget buildTitle(String title) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      width: double.infinity,
      color: theme.dividerColor.withAlpha(10),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: getFadeTextStyle(context),
      ),
    );
  }

  Future<List<List<Uid>>> searchUidList(String query) async {
    return [
      //in contacts
      await _contactRepo.searchInContacts(query),
      //in rooms
      await _roomRepo.searchInRooms(query),
    ];
  }

  Future<List<Uid>> globalSearchUser(String query) {
    return _contactRepo.searchUser(query);
  }

  List<Widget> searchResultWidget(List<Uid> uidList) {
    return List.generate(
      uidList.length,
      (index) {
        return RoomInformationWidget(
          uid: uidList[index],
        );
      },
    );
  }
}
