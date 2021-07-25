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
import 'package:deliver_flutter/services/audio_service.dart';
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
import 'package:deliver_flutter/shared/constants.dart';

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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:dart_vlc/dart_vlc.dart';

Future<void> setupDI() async {
  // Setup Logger
  GetIt.I.registerSingleton<DeliverLogFilter>(DeliverLogFilter());
  GetIt.I.registerSingleton<Logger>(Logger(
      filter: GetIt.I.get<DeliverLogFilter>(),
      level: kDebugMode ? Level.info : Level.nothing));

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

  GetIt.I.registerSingleton<AvatarDao>(AvatarDaoImpl());
  GetIt.I.registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  GetIt.I.registerSingleton<SharedDao>(SharedDaoImpl());
  GetIt.I.registerSingleton<UidIdNameDao>(UidIdNameDaoImpl());
  GetIt.I.registerSingleton<SeenDao>(SeenDaoImpl());
  GetIt.I.registerSingleton<FileDao>(FileDaoImpl());
  GetIt.I.registerSingleton<BlockDao>(BlockDaoImpl());
  GetIt.I.registerSingleton<MuteDao>(MuteDaoImpl());
  GetIt.I.registerSingleton<MucDao>(MucDaoImpl());
  GetIt.I.registerSingleton<BotDao>(BotDaoImpl());
  GetIt.I.registerSingleton<ContactDao>(ContactDaoImpl());
  GetIt.I.registerSingleton<MessageDao>(MessageDaoImpl());
  GetIt.I.registerSingleton<RoomDao>(RoomDaoImpl());
  GetIt.I.registerSingleton<MediaDao>(MediaDaoImpl());
  GetIt.I.registerSingleton<MediaMetaDataDao>(MediaMetaDataDaoImpl());

  // Order is important, don't change it!
  GetIt.I.registerSingleton<AuthServiceClient>(
      AuthServiceClient(ProfileServicesClientChannel));
  GetIt.I.registerSingleton<AuthRepo>(AuthRepo());
  GetIt.I
      .registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());

  GetIt.I.registerSingleton<UserServiceClient>(UserServiceClient(
      ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<ContactServiceClient>(ContactServiceClient(
      ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<QueryServiceClient>(QueryServiceClient(
      QueryClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<CoreServiceClient>(CoreServiceClient(
      CoreServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<BotServiceClient>(BotServiceClient(BotClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<StickerServiceClient>(StickerServiceClient(
      StickerClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<GroupServiceClient>(GroupServiceClient(
      MucServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<ChannelServiceClient>(ChannelServiceClient(
      MucServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<AvatarServiceClient>(AvatarServiceClient(
      AvatarServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<FirebaseServiceClient>(FirebaseServiceClient(
      FirebaseServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));

  GetIt.I.registerSingleton<SessionServiceClient>(SessionServiceClient(
      ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));

  GetIt.I.registerSingleton<AccountRepo>(AccountRepo());
  GetIt.I.registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  GetIt.I.registerSingleton<UxService>(UxService());
  GetIt.I.registerSingleton<FileService>(FileService());
  GetIt.I.registerSingleton<MucServices>(MucServices());
  GetIt.I.registerSingleton<CreateMucService>(CreateMucService());

  GetIt.I.registerSingleton<BotRepo>(BotRepo());
  GetIt.I.registerSingleton<StickerRepo>(StickerRepo());
  GetIt.I.registerSingleton<FileRepo>(FileRepo());
  GetIt.I.registerSingleton<ContactRepo>(ContactRepo());
  GetIt.I.registerSingleton<AvatarRepo>(AvatarRepo());
  GetIt.I.registerSingleton<RoutingService>(RoutingService());
  GetIt.I.registerSingleton<NotificationServices>(NotificationServices());
  GetIt.I.registerSingleton<MucRepo>(MucRepo());
  GetIt.I.registerSingleton<RoomRepo>(RoomRepo());
  GetIt.I.registerSingleton<CoreServices>(CoreServices());
  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
  GetIt.I.registerSingleton<AudioService>(AudioService());
  GetIt.I.registerSingleton<VideoPlayerService>(VideoPlayerService());
  GetIt.I.registerSingleton<MediaQueryRepo>(MediaQueryRepo());
  GetIt.I.registerSingleton<FireBaseServices>(FireBaseServices());
  GetIt.I.registerSingleton<LastActivityRepo>(LastActivityRepo());
}

Future setupFlutterNotification() async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger().i("Application has been started.");

  if (isDesktop()) {
    try {
      _setWindowSize();

      setWindowTitle(APPLICATION_NAME);
    } catch (e) {
      Logger().e(e);
    }
  }

  if (isLinux() || isWindows()) {
    DartVLC.initialize();
  }

  // TODO add IOS and MacOS too
  if (isAndroid()) {
    await setupFlutterNotification();
  }

  Logger().i("OS based setups done.");

  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }

  Logger().i("Dependency Injection setup done.");

  runApp(MyApp());
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
          child: Focus(
              focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
              onKey: (_, RawKeyEvent event) {
                return event.physicalKey == PhysicalKeyboardKey.shiftRight
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              },
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Deliver',
                locale: uxService.locale,
                theme: uxService.theme,
                supportedLocales: [Locale('en', 'US'), Locale('fa', 'IR')],
                localizationsDelegates: [
                  I18N.delegate,
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
              )),
        );
      },
    );
  }
}
