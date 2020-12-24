import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MuteAndUnMuteRoomWidget extends StatelessWidget {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final String roomId;

  MuteAndUnMuteRoomWidget({Key key, this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _appLocalization = AppLocalization.of(context);
    return Container(
      color: Theme.of(context).buttonColor,
      height: 45,
      child: Center(
          child: GestureDetector(
        child: StreamBuilder<Room>(
          stream: _roomRepo.roomIsMute(roomId),
          builder: (BuildContext context, AsyncSnapshot<Room> room) {
            if (room.data != null) {
              if (room.data.mute) {
                return GestureDetector(
                  child: Text(
                    _appLocalization.getTraslateValue("un_mute"),
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _roomRepo.changeRoomMuteTye(roomId: roomId, mute: false);
                  },
                );
              } else {
                return GestureDetector(
                  child: Text(
                    _appLocalization.getTraslateValue("mute"),
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _roomRepo.changeRoomMuteTye(roomId: roomId, mute: true);
                  },
                );
              }
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      )),
    );
  }
}
