import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_uid_message_widget.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
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
      await handleUri(initialLink, context);
    } on PlatformException {
      debug("deep link exception");
    } catch (e) {
      debug("%%%%%%%%%%%%%%%%+${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    _notificationServices.cancelAllNotification();
    checkIfUsernameIsSet();
    initUniLinks(context);
    if (isAndroid()) {
      checkShareFile(context);
    }
    _coreServices.initStreamConnection();
  }

  checkShareFile(BuildContext context) {
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value != null) {
        Fluttertoast.showToast(msg: value.length.toString());
        List<String> paths = List();
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

Future<void> handleUri(String initialLink, BuildContext context) async {
  var _mucDao = GetIt.I.get<MucDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var m = initialLink.toString().split("/");

  Uid mucUid;
  if (m[4].toString().contains("GROUP")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.GROUP;
  } else if (m[4].toString().contains("CHANNEL")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.CHANNEL;
  }
  if (mucUid != null) {
    var muc = await _mucDao.getMucByUid(mucUid.asString());
    if (muc != null) {
      _routingService.openRoom(mucUid.asString());
    } else {
      showFloatingModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalization.of(context)
                          .getTraslateValue("skip"))),
                  ElevatedButton(
                    onPressed: () async {
                      if (mucUid.category == Categories.GROUP) {
                        var res =
                            await _mucRepo.joinGroup(mucUid, m[6].toString());
                           _messageRepo.updateNewChannel(mucUid);
                        if (res) {
                          _routingService.openRoom(mucUid.asString());
                          Navigator.of(context).pop();
                        }
                      } else {
                        var res = await _mucRepo.joinChannel(mucUid, m[6]);
                        if (res) {
                          _messageRepo.updateNewChannel(mucUid);
                          _routingService.openRoom(mucUid.asString());
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("join")),
                  ),

                ],
              ),
            ],
          ),
        ),
      );
    }
  } else {
    print("%%%%%%%%%%%%%%%%%");
  }
}
