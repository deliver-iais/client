import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MucAppbarTitle extends StatelessWidget {
  final String mucUid;

  const MucAppbarTitle({Key key, this.mucUid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    GroupDao groupDao = GetIt.I.get<GroupDao>();
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<Group>(
        stream: groupDao.getByUid(mucUid),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${snapshot.data.members} ' +
                      appLocalization.getTraslateValue("members"),
                  style: TextStyle(fontSize: 11),
                ),
              ],
            );
          else
            return Container();
        });
  }
}
