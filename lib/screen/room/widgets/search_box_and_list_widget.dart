import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchBoxAndListWidget extends StatelessWidget {
  static final roomRepo = GetIt.I.get<RoomRepo>();
  static final authRepo = GetIt.I.get<AuthRepo>();
  static final queryTermDebouncedSubject = BehaviorSubject<String>.seeded("");

  final Widget Function(List<Uid>) listWidget;
  final Widget emptyWidget;

  const SearchBoxAndListWidget({
    super.key,
    required this.listWidget,
    required this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBox(
          onChange: queryTermDebouncedSubject.add,
          onCancel: () => queryTermDebouncedSubject.add(""),
        ),
        StreamBuilder<String>(
          stream: queryTermDebouncedSubject,
          builder: (context, query) {
            return Expanded(
              child: query.data == null || query.data!.isEmpty
                  ? FutureBuilder<List<Uid>>(
                      future: roomRepo.getAllRooms(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          if (snapshot.data!
                              .map((e) => e.asString())
                              .contains(authRepo.currentUserUid.asString())) {
                            final index = snapshot.data!
                                .map((e) => e.asString())
                                .toList()
                                .indexOf(authRepo.currentUserUid.asString());
                            snapshot.data!.removeAt(index);
                          }
                          snapshot.data!.insert(0, authRepo.currentUserUid);
                          return listWidget(snapshot.data!);
                        } else {
                          return emptyWidget;
                        }
                      },
                    )
                  : StreamBuilder<List<UidIdName>>(
                      stream: roomRepo.searchInRooms(query.data!),
                      builder: (c, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          if (snapshot.data!
                              .map((e) => e.uid.asString())
                              .contains(authRepo.currentUserUid.asString())) {
                            final index = snapshot.data!
                                .map((e) => e.uid.asString())
                                .toList()
                                .indexOf(authRepo.currentUserUid.asString());
                            snapshot.data!.removeAt(index);
                          }
                          snapshot.data!.insert(
                            0,
                            UidIdName(uid: authRepo.currentUserUid),
                          );
                          return listWidget(
                            snapshot.data!.map((e) => e.uid).toList(),
                          );
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
