import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AppbarPic extends StatefulWidget {
  @override
  _AppbarPicState createState() => _AppbarPicState();
}

class _AppbarPicState extends State<AppbarPic> {
  var accountRepo = GetIt.I.get<AccountRepo>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ExtendedNavigator.of(context).push(Routes.settingsPage);
      },
      child: CircleAvatarWidget(accountRepo.currentUserUid,"JD", 19,true),
    );
  }
}
