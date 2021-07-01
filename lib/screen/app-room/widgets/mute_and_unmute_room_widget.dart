import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MuteAndUnMuteRoomWidget extends StatelessWidget {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _memberRepo = GetIt.I.get<MemberRepo>();
  final String roomId;
  final Widget inputMessage;
  var _accountRpo = GetIt.I.get<AccountRepo>();

  MuteAndUnMuteRoomWidget({Key key, this.roomId, this.inputMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _appLocalization = AppLocalization.of(context);
    return FutureBuilder<bool>(
        future: _memberRepo.isMucAdminOrOwner(
            _accountRpo.currentUserUid.asString(), this.roomId),
        builder: (c, s) {
          if (s.hasData && s.data) {
            return this.inputMessage;
          } else {
            return Container(
              color: Theme.of(context).primaryColor,
              height: 45,
              child: Center(
                  child: GestureDetector(
                child: StreamBuilder<bool>(
                  stream: _roomRepo.watchIsRoomMuted(roomId),
                  builder: (BuildContext context, AsyncSnapshot<bool> isMuted) {
                    if (isMuted.data != null) {
                      if (isMuted.data) {
                        return GestureDetector(
                          child: Text(
                            _appLocalization.getTraslateValue("un_mute"),
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _roomRepo.unmute(roomId);
                          },
                        );
                      } else {
                        return GestureDetector(
                          child: Text(
                            _appLocalization.getTraslateValue("mute"),
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _roomRepo.mute(roomId);
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
        });
  }
}
