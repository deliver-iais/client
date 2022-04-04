import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';

import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/share_input_file/share_file_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShareInputFile extends StatefulWidget {
  final List<String> inputSharedFilePath;

  const ShareInputFile({required this.inputSharedFilePath, Key? key})
      : super(key: key);

  @override
  State<ShareInputFile> createState() => _ShareInputFileState();
}

class _ShareInputFileState extends State<ShareInputFile> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  final BehaviorSubject<String> _queryTermDebouncedSubject =
      BehaviorSubject<String>.seeded("");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _i18n.get("send_To"),
        ),
        leading: _routingServices.backButtonLeading(),
      ),
      body: Column(
        children: <Widget>[
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
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (ctx, index) {
                          return ChatItemToShareFile(
                            uid: snapshot.data![index],
                            sharedFilePath: widget.inputSharedFilePath,
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
