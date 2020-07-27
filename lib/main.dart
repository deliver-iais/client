import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/profileRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/downloadFile.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:rxdart/rxdart.dart';
import './db/dao/MessageDao.dart';
import 'db/dao/RoomDao.dart';
import 'repository/servicesDiscoveryRepo.dart';

void setupDI() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<CurrentPageService>(CurrentPageService());
  getIt.registerSingleton<AccountRepo>(AccountRepo());
  getIt.registerSingleton<ProfileRepo>(ProfileRepo());
  getIt.registerSingleton<AvatarRepo>(AvatarRepo());
  getIt.registerSingleton<ServicesDiscoveryRepo>(ServicesDiscoveryRepo());
  getIt.registerSingleton<DownloadFile>(DownloadFile());
  Database db = Database();
  getIt.registerSingleton<MessageDao>(db.messageDao);
  getIt.registerSingleton<RoomDao>(db.roomDao);
  getIt.registerSingleton<AvatarDao>(db.avatarDao);
  getIt.registerSingleton<ContactDao>(db.contactDao);
  getIt.registerSingleton<FileDao>(db.fileDao);
  getIt.registerSingleton<FileRepo>(FileRepo());
  FlutterDownloader.initialize();

  PermissionsPlugin
      .requestPermissions([
    Permission.WRITE_EXTERNAL_STORAGE,
    Permission.READ_EXTERNAL_STORAGE,
    Permission.READ_CONTACTS,
  ]);
  // Creates dir/ and dir/subdir/.
}

void main() {
  runApp(MyApp());
  setupDI();


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

        return ExtraTheme(
          extraThemeData: uxService.extraTheme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: uxService.theme,
            onGenerateRoute: Router(),
            builder: ExtendedNavigator<Router>(
              router: Router(),
            ),
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
