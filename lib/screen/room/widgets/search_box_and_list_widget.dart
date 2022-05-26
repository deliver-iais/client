import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBoxAndListWidget extends StatelessWidget {
  final Widget Function(List<Uid>) listWidget;
  final Widget emptyWidget;

  const SearchBoxAndListWidget({
    Key? key,
    required this.listWidget,
    required this.emptyWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _queryTermDebouncedSubject = BehaviorSubject<String>.seeded("");
    final _roomRepo = GetIt.I.get<RoomRepo>();
    final _authRepo = GetIt.I.get<AuthRepo>();
    return Column(
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
                    if (snapshot.data!
                        .map((e) => e.asString())
                        .contains(_authRepo.currentUserUid.asString())) {
                      final index = snapshot.data!
                          .map((e) => e.asString())
                          .toList()
                          .indexOf(_authRepo.currentUserUid.asString());
                      snapshot.data!.removeAt(index);
                    }
                    snapshot.data!.insert(0, _authRepo.currentUserUid);
                    return listWidget(snapshot.data!);
                  } else {
                    return emptyWidget;
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
