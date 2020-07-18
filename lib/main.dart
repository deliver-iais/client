import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import './db/dao/MessageDao.dart';
import 'db/dao/RoomDao.dart';

void setupDI() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<CurrentPageService>(CurrentPageService());
  Database db = Database();
  getIt.registerSingleton<MessageDao>(db.messageDao);
  getIt.registerSingleton<RoomDao>(db.roomDao);
}

void main() {
  setupDI();

  runApp(MyApp());

  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Application has been started");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uxService = GetIt.I.get<UxService>();
    var currentPageService = GetIt.I.get<CurrentPageService>();
    var messagesDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder(
      stream: MergeStream([
        uxService.themeStream as Stream,
        currentPageService.currentPageStream as Stream,
        messagesDao.watchAllMessages(),
        roomDao.watchAllRooms(),
      ]),
      builder: (context, snapshot) {
        Fimber.d("theme changed ${uxService.theme.toString()}");
        Fimber.d(
            "currentPage changed ${currentPageService.currentPage.toString()}");

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: uxService.theme,
          onGenerateRoute: Router(),
          builder: ExtendedNavigator<Router>(
            router: Router(),
          ),
        );
      },
    );
  }
}

//TODO
//ConvertTime To Shared
//edit details
//edit ChatItem
//delete extra models
//edit address of files
//userid for chat item
//message doesnt send in database?
