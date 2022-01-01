import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';

import 'package:deliver/screen/navigation_center/widgets/search_box.dart';
import 'package:deliver/screen/share_input_file/share_file_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareInputFile extends StatelessWidget {
  final List<String> inputSharedFilePath;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();

  ShareInputFile({required this.inputSharedFilePath, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    I18N i18n = GetIt.I.get<I18N>();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          i18n.get("send_To"),
          style: TextStyle(color: ExtraTheme.of(context).textField),
        ),
        leading: _routingServices.backButtonLeading(context),
      ),
      body: Column(
        children: <Widget>[
          SearchBox(
            onChange: (f) {},
          ),
          Expanded(
            child: FutureBuilder<List<Uid>>(
              future: _roomRepo.getAllRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return ChatItemToShareFile(
                        uid: snapshot.data![index],
                        sharedFilePath: inputSharedFilePath,
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
