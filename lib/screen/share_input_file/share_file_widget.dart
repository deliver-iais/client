
import 'package:deliver/repository/roomRepo.dart';

import 'package:deliver/screen/navigation_center/chats/widgets/contact_pic.dart';
import 'package:deliver/screen/room/pages/room_page.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToShareFile extends StatelessWidget {
  final Uid uid;
  final List<String>? sharedFilePath;
  final String? sharedText;
  final _roomRepo = GetIt.I.get<RoomRepo>();

  ChatItemToShareFile(
      {Key? key, required this.uid, this.sharedText, this.sharedFilePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 12,
              ),
              ContactPic(uid),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                child: FutureBuilder(
                    future: _roomRepo.getName(uid),
                    builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                      if (snaps.hasData && snaps.data != null) {
                        return Text(
                          snaps.data!,
                          style: TextStyle(
                            color:
                                ExtraTheme.of(context).chatOrContactItemDetails,
                            fontSize: 18,
                          ),
                        );
                      } else {
                        return Text(
                          "unKnown",
                          style: TextStyle(
                            color:
                                ExtraTheme.of(context).chatOrContactItemDetails,
                            fontSize: 18,
                          ),
                        );
                      }
                    }),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return RoomPage(
                      roomId: uid.asString(),
                      inputFilePath: sharedFilePath,
                    );
                  }));
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
