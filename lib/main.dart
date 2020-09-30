import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/dao/LastAvatarDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart' as R;
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_flutter/services/message_service.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/services/video_player_service.dart';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:fimber/fimber.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:window_size/window_size.dart';
import 'db/dao/MessageDao.dart';
import 'db/dao/GroupDao.dart';
import 'db/dao/RoomDao.dart';
import 'repository/mucRepo.dart';
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
  getIt.registerSingleton<MediaDao>(db.mediaDao);
  getIt.registerSingleton<PendingMessageDao>(db.pendingMessageDao);
  getIt.registerSingleton<LastAvatarDao>(db.lastAvatarDao);
  getIt.registerSingleton<SharedPreferencesDao>(db.sharedPreferencesDao);
  getIt.registerSingleton<GroupDao>(db.groupDao);
  getIt.registerSingleton<MemberDao>(db.memberDao);
}

void setupRepositories() {
  // Order is important, don't change it!
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<AccountRepo>(AccountRepo());
  getIt.registerSingleton<ServicesDiscoveryRepo>(ServicesDiscoveryRepo());
  getIt.registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  getIt.registerSingleton<MessageService>(MessageService());
  getIt.registerSingleton<FileService>(FileService());
  getIt.registerSingleton<FileRepo>(FileRepo());
  getIt.registerSingleton<AvatarRepo>(AvatarRepo());
  getIt.registerSingleton<MessageRepo>(MessageRepo());
  getIt.registerSingleton<MucServices>(MucServices());
  getIt.registerSingleton<RoomRepo>(RoomRepo());
  getIt.registerSingleton<ContactRepo>(ContactRepo());
  getIt.registerSingleton<MucRepo>(MucRepo());
  getIt.registerSingleton<AudioPlayerService>(AudioPlayerService());
  getIt.registerSingleton<VideoPlayerService>(VideoPlayerService());
  getIt.registerSingleton<NotificationServices>(NotificationServices());
  getIt.registerSingleton<MediaQueryRepo>(MediaQueryRepo());
  getIt.registerSingleton<MemberRepo>(MemberRepo());
  getIt.registerSingleton<FireBaseServices>(FireBaseServices());
  getIt.registerSingleton<CreateMucService>(CreateMucService());
  getIt.registerSingleton<RoutingService>(RoutingService());
}

setupFlutterNotification()async {
  await Firebase.initializeApp();
}

void setupDIAndRunApp() {
  setupDB();
  setupRepositories();
  setupFlutterNotification();
  runApp(MyApp());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree.elapsed());
  Fimber.i("Application has been started");

  if (isDesktop()) {
    _setWindowSize();

    setWindowTitle("Deliver");
  }

  if (isAndroid()) {
    SmsAutoFill()
        .getAppSignature
        .then((signCode) => Fimber.d("APP_SIGN_CODE for SMS: $signCode"));
  }

  setupDIAndRunApp();
}

_setWindowSize() async {
  var platformWindow = await getWindowInfo();
  setWindowMinSize(Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100));
  setWindowMaxSize(Size(
      platformWindow.screen.frame.width, platformWindow.screen.frame.height));
}

// DynamicLibrary _openOnLinux() {
//   final script = File(Platform.script.toFilePath());
//   final libraryNextToScript = File('${script.path}/sqlite3');
//   return DynamicLibrary.open(libraryNextToScript.path);
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uxService = GetIt.I.get<UxService>();
    return StreamBuilder(
      stream: MergeStream([
        uxService.themeStream as Stream,
        uxService.localeStream as Stream,
      ]),
      builder: (context, snapshot) {
        Fimber.d("theme changed ${uxService.theme.toString()}");
        return ExtraTheme(
          extraThemeData: uxService.extraTheme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            locale: uxService.locale,
            theme: uxService.theme,
            supportedLocales: [Locale('en', 'US'), Locale('fa', 'IR')],
            localizationsDelegates: [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            localeResolutionCallback: (deviceLocale, supportedLocale) {
              for (var locale in supportedLocale) {
                if (locale.languageCode == deviceLocale.languageCode &&
                    locale.countryCode == deviceLocale.countryCode) {
                  return deviceLocale;
                }
              }
              return supportedLocale.first;
            },
            onGenerateRoute: R.Router(),
            builder: (x, c) => Directionality(
              textDirection: TextDirection.ltr,
              child: ExtendedNavigator<R.Router>(
                router: R.Router(),
              ),
            ),
          ),
        );
      },
    );
  }
}
