import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class JointToMucWidget extends StatelessWidget {
  final Uid mucUid;
  final String token;

  JointToMucWidget(this.mucUid,this.token);

  var _mucRepo = GetIt.I.get<MucRepo>();
  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Container(
        height: 45,
        color: Theme.of(context).primaryColor,
        child: Center(
          child: GestureDetector(
            child: Text(_appLocalization.getTraslateValue("join")),
            onTap: () {
              mucUid.category == Categories.GROUP
                  ? _mucRepo.joinGroup(mucUid,token)
                  : _mucRepo.joinChannel(mucUid,token);
            },
          ),
        ));
  }
}
