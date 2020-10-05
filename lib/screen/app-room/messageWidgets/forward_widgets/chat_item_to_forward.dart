import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/contactPic.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToForward extends StatelessWidget {
  final Uid uid;
  final List<Message> forwardedMessages;

  ChatItemToForward({Key key, this.uid,this.forwardedMessages}) : super(key: key);
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _routingService = GetIt.I.get<RoutingService>();


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      child: Container(
        height: 40,
        child: Expanded(
          child: Row(
            children: <Widget>[
              ContactPic(true, uid),
              SizedBox(
                width: 12,
              ),
              FutureBuilder(
                  future: _roomRepo.getRoomDisplayName(uid),
                  builder: (BuildContext c, AsyncSnapshot<String> snaps) {
                    if(snaps.hasData && snaps.data!= null){
                      return Text(snaps.data,
                        style: TextStyle(
                          color: ExtraTheme.of(context).infoChat,
                          fontSize: 18,
                        ),
                      );
                    }else{
                      return Text("unKnown",
                        style: TextStyle(
                          color: ExtraTheme.of(context).infoChat,
                          fontSize: 18,
                        ),
                      );
                    }

                  }),
              Spacer(),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).accentColor,
                ),
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.center,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: ExtraTheme.of(context).active,
                  ),
                  onPressed: (){
                    _routingService.openRoom(uid.getString(),forwardedMessages: forwardedMessages);
                  },
                ),
              )
            ],
          ),
        )

      ),
    );
  }
}
