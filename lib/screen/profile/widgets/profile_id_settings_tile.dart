import 'package:deliver/box/muc.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/widgets/settings_ui/src/settings_tile.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileIdSettingsTile extends StatefulWidget {
  @required
  final Uid roomUid;
  @required
  final ThemeData theme;

  const ProfileIdSettingsTile(this.roomUid, this.theme, {super.key});

  @override
  ProfileIdSettingsTileState createState() => ProfileIdSettingsTileState();
}

class ProfileIdSettingsTileState extends State<ProfileIdSettingsTile> {
  static final _i18n = GetIt.I.get<I18N>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    if (widget.roomUid.isChannel()) {
      return StreamBuilder<Muc?>(
        stream: _mucRepo.watchMuc(widget.roomUid.asString()),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: SettingsTile(
                title: _i18n.get("username"),
                subtitle: snapshot.data?.id ?? "",
                leading: const Icon(Icons.alternate_email),
                trailing: const Icon(Icons.copy),
                subtitleTextStyle: TextStyle(color: widget.theme.colorScheme.primary),
                onPressed: (_) => saveToClipboard("@${snapshot.data!.id}"),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }
    if (!widget.roomUid.isGroup()) {
      return StreamBuilder<String?>(
        stream: _roomRepo.watchId(widget.roomUid),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(top: 8.0),
              child: SettingsTile(
                title: _i18n.get("username"),
                subtitle: "${snapshot.data}",
                leading: const Icon(Icons.alternate_email),
                trailing: const Icon(Icons.copy),
                subtitleTextStyle: TextStyle(color: widget.theme.colorScheme.primary),
                onPressed: (_) => saveToClipboard("@${snapshot.data!}"),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }
    return const SizedBox.shrink();
  }
}
