import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatItemToForward extends StatelessWidget {
  final Uid uid;
  final void Function(Uid) send;

  ChatItemToForward({Key? key, required this.uid, required this.send})
      : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 12,
              ),
              CircleAvatarWidget(uid, 30, showSavedMessageLogoIfNeeded: true),
              // ContactPic(true, uid),
              const SizedBox(
                width: 12,
              ),
              Flexible(
                child: FutureBuilder<String>(
                  future: _roomRepo.getName(uid),
                  builder: (c, snaps) {
                    if (snaps.hasData && snaps.data != null) {
                      return Text(
                        _authRepo.isCurrentUser(uid.asString())
                            ? _i18n.get("saved_message")
                            : snaps.data!,
                        style: const TextStyle(fontSize: 18),
                        overflow:TextOverflow.ellipsis ,
                      );
                    } else {
                      return const Text(
                        "Unknown",
                        style: TextStyle(fontSize: 18),
                      );
                    }
                  },
                ),
              ),

            ],
          ),
        ),
      ),
      onTap: () => send(uid),
    );
  }
}
