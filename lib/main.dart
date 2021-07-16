import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/bot_info.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/dao/avatar_dao.dart';
import 'package:deliver_flutter/box/dao/block_dao.dart';
import 'package:deliver_flutter/box/dao/bot_dao.dart';
import 'package:deliver_flutter/box/dao/file_dao.dart';
import 'package:deliver_flutter/box/dao/last_activity_dao.dart';
import 'package:deliver_flutter/box/dao/mute_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/box/file_info.dart';
import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:deliver_flutter/box/media_type.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/role.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/box/sending_status.dart';
import 'package:deliver_flutter/box/uid_id_name.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
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
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_size/window_size.dart';
import 'box/dao/contact_dao.dart';
import 'box/dao/media_dao.dart';
import 'box/dao/media_meta_data_dao.dart';
import 'box/dao/message_dao.dart';
import 'box/dao/muc_dao.dart';
import 'box/media.dart';
import 'repository/mucRepo.dart';

Future<void> setupDI() async {
  await Hive.initFlutter("db");

  Hive.registerAdapter(AvatarAdapter());
  Hive.registerAdapter(LastActivityAdapter());
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(UidIdNameAdapter());
  Hive.registerAdapter(SeenAdapter());
  Hive.registerAdapter(FileInfoAdapter());
  Hive.registerAdapter(MucAdapter());
  Hive.registerAdapter(MucRoleAdapter());
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(BotInfoAdapter());
  Hive.registerAdapter(RoomAdapter());
  Hive.registerAdapter(PendingMessageAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  Hive.registerAdapter(SendingStatusAdapter());
  Hive.registerAdapter(MediaAdapter());
  Hive.registerAdapter(MediaMetaDataAdapter());
  Hive.registerAdapter(MediaTypeAdapter());

  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AvatarDao>(AvatarDaoImpl());
  getIt.registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  getIt.registerSingleton<SharedDao>(SharedDaoImpl());
  getIt.registerSingleton<UidIdNameDao>(UidIdNameDaoImpl());
  getIt.registerSingleton<SeenDao>(SeenDaoImpl());
  getIt.registerSingleton<FileDao>(FileDaoImpl());
  getIt.registerSingleton<BlockDao>(BlockDaoImpl());
  getIt.registerSingleton<MuteDao>(MuteDaoImpl());
  getIt.registerSingleton<MucDao>(MucDaoImpl());
  getIt.registerSingleton<BotDao>(BotDaoImpl());
  getIt.registerSingleton<ContactDao>(ContactDaoImpl());
  getIt.registerSingleton<MessageDao>(MessageDaoImpl());
  getIt.registerSingleton<RoomDao>(RoomDaoImpl());
  getIt.registerSingleton<MediaDao>(MediaDaoImpl());
  getIt.registerSingleton<MediaMetaDataDao>(MediaMetaDataDaoImpl());

  // Order is important, don't change it!
  getIt.registerSingleton<AuthServiceClient>(
      AuthServiceClient(ProfileServicesClientChannel));
  getIt.registerSingleton<AuthRepo>(AuthRepo());
  getIt.registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());

  getIt.registerSingleton<UserServiceClient>(UserServiceClient(
      ProfileServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<ContactServiceClient>(ContactServiceClient(
      ProfileServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<QueryServiceClient>(QueryServiceClient(
      QueryClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<CoreServiceClient>(CoreServiceClient(
      CoreServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<BotServiceClient>(BotServiceClient(BotClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<StickerServiceClient>(StickerServiceClient(
      StickerClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<GroupServiceClient>(GroupServiceClient(
      MucServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<ChannelServiceClient>(ChannelServiceClient(
      MucServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<AvatarServiceClient>(AvatarServiceClient(
      AvatarServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));
  getIt.registerSingleton<FirebaseServiceClient>(FirebaseServiceClient(
      FirebaseServicesClientChannel,
      interceptors: [getIt.get<DeliverClientInterceptor>()]));

  getIt.registerSingleton<AccountRepo>(AccountRepo());
  getIt.registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  getIt.registerSingleton<UxService>(UxService());
  getIt.registerSingleton<FileService>(FileService());
  getIt.registerSingleton<MucServices>(MucServices());
  getIt.registerSingleton<CreateMucService>(CreateMucService());

  getIt.registerSingleton<BotRepo>(BotRepo());
  getIt.registerSingleton<StickerRepo>(StickerRepo());
  getIt.registerSingleton<FileRepo>(FileRepo());
  getIt.registerSingleton<ContactRepo>(ContactRepo());
  getIt.registerSingleton<AvatarRepo>(AvatarRepo());
  getIt.registerSingleton<RoutingService>(RoutingService());
  getIt.registerSingleton<NotificationServices>(NotificationServices());
  getIt.registerSingleton<MucRepo>(MucRepo());
  getIt.registerSingleton<RoomRepo>(RoomRepo());
  getIt.registerSingleton<CoreServices>(CoreServices());

  getIt.registerSingleton<MessageRepo>(MessageRepo());

  getIt.registerSingleton<AudioPlayerService>(AudioPlayerService());
  getIt.registerSingleton<VideoPlayerService>(VideoPlayerService());

  getIt.registerSingleton<MediaQueryRepo>(MediaQueryRepo());

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
  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }

  // TODO: Android just now is available

  runApp(MyApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger().d("Application has been started");

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
