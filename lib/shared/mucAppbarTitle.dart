import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/services/mode_checker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'methods/enum_helper_methods.dart';

class MucAppbarTitle extends StatelessWidget {
  final String mucUid;

  const MucAppbarTitle({Key key, this.mucUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var modeChecker = GetIt.I.get<ModeChecker>();
    GroupDao groupDao = GetIt.I.get<GroupDao>();
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<Group>(
        stream: groupDao.getByUid(mucUid),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return StreamBuilder<AppMode>(
                stream: modeChecker.appMode,
                builder: (context, mode) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data.name,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        mode.data != AppMode.STABLE
                            ? Text(enumToString(mode.data ?? AppMode.CONNECTING)
                                    .toLowerCase() +
                                '...')
                            : '${snapshot.data.members} ' +
                                appLocalization.getTraslateValue("members"),
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  );
                });
          else
            return Container();
        });
  }
}
