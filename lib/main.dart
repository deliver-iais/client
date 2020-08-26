import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/downloadFileServices.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import './db/dao/MessageDao.dart';
import 'db/dao/RoomDao.dart';
import 'repository/servicesDiscoveryRepo.dart';

void setupDB() {
  GetIt getIt = GetIt.instance;
  Database db = Database();
  getIt.registerSingleton<MessageDao>(db.messageDao);
  getIt.registerSingleton<RoomDao>(db.roomDao);
  getIt.registerSingleton<AvatarDao>(db.avatarDao);
  getIt.registerSingleton<ContactDao>(db.contactDao);
  getIt.registerSingleton<FileDao>(db.fileDao);
  getIt.registerSingleton<SeenDao>(db.seenDao);
}

void setupRepositories() {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<AccountRepo>(AccountRepo());
  getIt.registerSingleton<AvatarRepo>(AvatarRepo());
  getIt.registerSingleton<ServicesDiscoveryRepo>(ServicesDiscoveryRepo());
  getIt.registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  getIt.registerSingleton<DownloadFileServices>(DownloadFileServices());
  getIt.registerSingleton<MessageService>(MessageService());
  getIt.registerSingleton<FileService>(FileService());
  getIt.registerSingleton<FileRepo>(FileRepo());
  getIt.registerSingleton<AudioPlayerService>(AudioPlayerService());
}

void setupDIAndRunApp() {
  GetIt getIt = GetIt.instance;

  getIt.registerSingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
  getIt.allReady().then((_) {
    setupDB();
    setupRepositories();

    FlutterDownloader.initialize();

    runApp(MyApp());
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Application has been started");
  SmsAutoFill()
      .getAppSignature
      .then((signCode) => Fimber.d("APP_SIGN_CODE for SMS: $signCode"));

  setupDIAndRunApp();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uxService = GetIt.I.get<UxService>();
    var messagesDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder(
      stream: MergeStream([
        uxService.themeStream as Stream,
        messagesDao.watchAllMessages(),
        roomDao.watchAllRooms(),
      ]),
      builder: (context, snapshot) {
        Fimber.d("theme changed ${uxService.theme.toString()}");

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
