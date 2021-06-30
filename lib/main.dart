import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/dao/avatar_dao.dart';
import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:deliver_flutter/db/dao/BotInfoDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/MediaMetaDataDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/dao/StickerIdDao.dart';
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/repository/stickerRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart' as R;
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/check_permissions_service.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/services/video_player_service.dart';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_size/window_size.dart';
import 'db/dao/MessageDao.dart';
import 'db/dao/MucDao.dart';
import 'db/dao/RoomDao.dart';
import 'repository/mucRepo.dart';

void setupDI() async {
  await Hive.initFlutter("db");

  Hive.registerAdapter(AvatarAdapter());
  Hive.registerAdapter(LastActivityAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(UidIdNameAdapter());
  Hive.registerAdapter(SeenAdapter());

  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AvatarDao>(AvatarDaoImpl());
  getIt.registerSingleton<SharedDao>(SharedDaoImpl());
  getIt.registerSingleton<SeenDao>(SeenDaoImpl());

  Database db = Database();

  getIt.registerSingleton<Database>(db);
  getIt.registerSingleton<MessageDao>(db.messageDao);
  getIt.registerSingleton<RoomDao>(db.roomDao);
  getIt.registerSingleton<ContactDao>(db.contactDao);
  getIt.registerSingleton<FileDao>(db.fileDao);
  getIt.registerSingleton<MediaDao>(db.mediaDao);
  getIt.registerSingleton<PendingMessageDao>(db.pendingMessageDao);
  getIt.registerSingleton<MucDao>(db.mucDao);
  getIt.registerSingleton<MemberDao>(db.memberDao);
  getIt.registerSingleton<MediaMetaDataDao>(db.mediaMetaDataDao);
  getIt.registerSingleton<UserInfoDao>(db.userInfoDao);
  getIt.registerSingleton<StickerDao>(db.stickerDao);
  getIt.registerSingleton<StickerIdDao>(db.stickerIdDao);
  getIt.registerSingleton<BotInfoDao>(db.botInfoDao);

  // Order is important, don't change it!
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<QueryServiceClient>(
      QueryServiceClient(QueryClientChannel));
  getIt.registerSingleton<BotServiceClient>(BotServiceClient(BotClientChannel));
  getIt.registerSingleton<StickerServiceClient>(
      StickerServiceClient(StickerClientChannel));

  getIt.registerSingleton<AccountRepo>(AccountRepo());
  getIt.registerSingleton<BotRepo>(BotRepo());

  getIt.registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  getIt.registerSingleton<FileService>(FileService());
  getIt.registerSingleton<StickerRepo>(StickerRepo());
  getIt.registerSingleton<FileRepo>(FileRepo());
  getIt.registerSingleton<ContactRepo>(ContactRepo());
  getIt.registerSingleton<MucServices>(MucServices());
  getIt.registerSingleton<AvatarRepo>(AvatarRepo());
  getIt.registerSingleton<CreateMucService>(CreateMucService());
  getIt.registerSingleton<RoutingService>(RoutingService());
  getIt.registerSingleton<NotificationServices>(NotificationServices());
  getIt.registerSingleton<MucRepo>(MucRepo());
  getIt.registerSingleton<RoomRepo>(RoomRepo());
  getIt.registerSingleton<CoreServiceClient>(
      CoreServiceClient(CoreServicesClientChannel));
  getIt.registerSingleton<CoreServices>(CoreServices());

  getIt.registerSingleton<MessageRepo>(MessageRepo());

  getIt.registerSingleton<AudioPlayerService>(AudioPlayerService());
  getIt.registerSingleton<VideoPlayerService>(VideoPlayerService());

  getIt.registerSingleton<MediaQueryRepo>(MediaQueryRepo());

  getIt.registerSingleton<MemberRepo>(MemberRepo());

  getIt.registerSingleton<FireBaseServices>(FireBaseServices());
  getIt.registerSingleton<LastActivityRepo>(LastActivityRepo());
}

Future setupFlutterNotification() async {
  await Firebase.initializeApp();
}

void setupDIAndRunApp() async {
  if (isAndroid()) {
    await setupFlutterNotification();
  }
  await setupDI();

  // TODO: Android just now is available

  runApp(MyApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debug("Application has been started");

  if (isDesktop()) {
    _setWindowSize();

    setWindowTitle("Deliver");
  }

  setupDIAndRunApp();
}

_setWindowSize() async {
  var platformWindow = await getWindowInfo();
  setWindowMinSize(Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100));
  setWindowMaxSize(Size(
      platformWindow.screen.frame.width, platformWindow.screen.frame.height));
}

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
        return ExtraTheme(
          extraThemeData: uxService.extraTheme,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Deliver',
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
