import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/contactPic.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToShareFile extends StatelessWidget {
  final Uid uid;
  final List<String> sharedFilePath;
  final String sharedText;
  final _roomRepo = GetIt.I.get<RoomRepo>();

ChatItemToShareFile({Key key, this.uid, this.sharedText,this.sharedFilePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        child: Container(
            height: 50,
            child:  Row(
                children: <Widget>[
                  SizedBox(
                    width: 12,
                  ),
                  ContactPic(uid),
                  SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    child: FutureBuilder(
                        future: _roomRepo.getName(uid),
                        builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                          if (snaps.hasData && snaps.data != null) {
                            return Text(
                              snaps.data,
                              style: TextStyle(
                                color: ExtraTheme.of(context).chatOrContactItemDetails,
                                fontSize: 18,
                              ),
                            );
                          } else {
                            return Text(
                              "unKnown",
                              style: TextStyle(
                                color: ExtraTheme.of(context).chatOrContactItemDetails,
                                fontSize: 18,
                              ),
                            );
                          }
                        }),
                    onTap: () {

                      ExtendedNavigator.of(context).push(Routes.roomPage,
                          arguments: RoomPageArguments(
                              roomId: uid.asString(),inputFilePath:sharedFilePath )
                      );
                    },
                  ),
                  Spacer(),
                ],
              ),
            ),
      ),
    );
  }
}
