import 'package:auto_route/auto_route.dart';


import 'package:deliver_flutter/repository/accountRepo.dart';

import 'package:deliver_flutter/routes/router.gr.dart';

import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/utils/log.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _coreServices = GetIt.I.get<CoreServices>();
  var _notificationServices = GetIt.I.get<NotificationServices>();

  Future<void> initUniLinks(BuildContext context) async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink.isNotEmpty) await handleUri(initialLink, context);
    } on PlatformException {
      debug("deep link exception");
    } catch (e) {
      debug("%%%%%%%%%%%%%%%%+${e.toString()}");
    }
  }

  @override
  void initState() {
    _notificationServices.cancelAllNotification();
    checkIfUsernameIsSet();
    initUniLinks(context);
    if (isAndroid()) {
      checkShareFile(context);
    }
    _coreServices.initStreamConnection();
    super.initState();
  }

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value != null) {
        Fluttertoast.showToast(msg: value.length.toString());
        List<String> paths = [];
        for (var path in value) {
          paths.add(path.path);
        }
        ExtendedNavigator.of(context).pushAndRemoveUntil(
            Routes.shareInputFile, (_) => false,
            arguments: ShareInputFileArguments(inputSharedFilePath: paths));
      }
    });
    // ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
    //   if (value != null) {
    //     List<String> paths = List();
    //     for (var path in value) {
    //       paths.add(path.path);
    //     }
    //     ExtendedNavigator.of(context).pushAndRemoveUntil(
    //         Routes.shareInputFile, (_) => false,
    //         arguments: ShareInputFileArguments(inputSharedFilePath: paths));
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_routingService.canPerformBackButton()) return true;
        _routingService.pop();
        return false;
      },
      child: StreamBuilder(
          stream: _routingService.currentRouteStream,
          builder: (context, snapshot) {
            return _routingService.routerOutlet(context);
          }),
    );
  }

  void checkIfUsernameIsSet() async {
    if (!await _accountRepo.getProfile(retry: true)) {
      _routingService.openAccountSettings(forceToSetUsernameAndName: true);
    } else {
      await _accountRepo.fetchProfile();
    }
  }
}
