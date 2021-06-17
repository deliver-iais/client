import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/firebase_services.dart';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedInStatus;
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  var _fireBaseServices = GetIt.I.get<FireBaseServices>();
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    tryInitAccountRepo();
  }

  tryInitAccountRepo() {
    _accountRepo.init().timeout(Duration(seconds: 2), onTimeout: () {
      if (attempts < 3) {
        attempts++;
        tryInitAccountRepo();
      } else {
        _navigateToIntroPage();
      }
    }).then((_) {
      _accountRepo.isLoggedIn() ? gotoRooms(context) : _navigateToIntroPage();
    });
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.of(context)
        .pushAndRemoveUntil(Routes.introPage, (_) => false);
  }

  gotoRooms(BuildContext context) async {
    /* var result = await ReceiveSharingIntent.getInitialMedia();
      if (result != null ) {
        List<String> paths = List();
        for(var path in result){
          paths.add(path.path);
        }
        ExtendedNavigator.of(context).push(
          Routes.shareInputFile,arguments: ShareInputFileArguments(inputSharedFilePath: paths)
        );
      } else {*/
    _navigateToHomePage();
    // }
  }

  void _navigateToHomePage() async {
    _fireBaseServices.sendFireBaseToken();
    bool setUserName = await _accountRepo.getProfile();
    if (setUserName) {
      ExtendedNavigator.of(context).pushAndRemoveUntil(
        Routes.homePage,
        (_) => false,
      );
    } else {
      ExtendedNavigator.of(context).push(Routes.accountSettings,
          arguments:
              AccountSettingsArguments(forceToSetUsernameAndName: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                  "assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png"),
            ),
          ),
        ],
      ),
    );
  }
}
