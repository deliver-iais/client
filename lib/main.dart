import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/live_location_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/livelocation.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/repository/stickerRepo.dart';
import 'package:deliver/screen/splash/splash_screen.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/firebase.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/group.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_size/window_size.dart';

import 'box/dao/contact_dao.dart';
import 'box/dao/custom_notication_dao.dart';
import 'box/dao/media_dao.dart';
import 'box/dao/media_meta_data_dao.dart';
import 'box/dao/message_dao.dart';
import 'box/dao/muc_dao.dart';
import 'box/media.dart';
import 'repository/mucRepo.dart';

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
  Hive.registerAdapter(LiveLocationAdapter());

  GetIt.I.registerSingleton<CustomNotificatonDao>(CustomNotificatonDaoImpl());
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
  GetIt.I.registerSingleton<DBManager>(DBManager());
  GetIt.I.registerSingleton<LiveLocationDao>(LiveLocationDaoImpl());

  GetIt.I.registerSingleton<I18N>(I18N());

  // Order is important, don't change it!
  GetIt.I.registerSingleton<AuthServiceClient>(AuthServiceClient(
      kIsWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel));
  GetIt.I.registerSingleton<RoutingService>(RoutingService());
  final authRepo = AuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(authRepo);
  await authRepo.setCurrentUserUid();
  GetIt.I
      .registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());

  GetIt.I.registerSingleton<UserServiceClient>(UserServiceClient(
      kIsWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<ContactServiceClient>(ContactServiceClient(
      kIsWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<QueryServiceClient>(QueryServiceClient(
      kIsWeb ? webQueryClientChannel : QueryClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<CoreServiceClient>(CoreServiceClient(
      kIsWeb ? webCoreServicesClientChannel : CoreServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<BotServiceClient>(BotServiceClient(
      kIsWeb ? webBotClientChannel : BotClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<StickerServiceClient>(StickerServiceClient(
      kIsWeb ? webStickerClientChannel : StickerClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<GroupServiceClient>(GroupServiceClient(
      kIsWeb ? webMucServicesClientChannel : MucServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<ChannelServiceClient>(ChannelServiceClient(
      kIsWeb ? webMucServicesClientChannel : MucServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<AvatarServiceClient>(AvatarServiceClient(
      kIsWeb ? webAvatarServicesClientChannel : AvatarServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<FirebaseServiceClient>(FirebaseServiceClient(
      kIsWeb ? webFirebaseServicesClientChannel : FirebaseServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));

  GetIt.I.registerSingleton<SessionServiceClient>(SessionServiceClient(
      kIsWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: [GetIt.I.get<DeliverClientInterceptor>()]));
  GetIt.I.registerSingleton<LiveLocationServiceClient>(
      LiveLocationServiceClient(
          kIsWeb
              ? webLiveLocationClientChannel
              : LiveLocationServiceClientChannel,
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
  GetIt.I.registerSingleton<MucRepo>(MucRepo());
  GetIt.I.registerSingleton<RoomRepo>(RoomRepo());
  GetIt.I.registerSingleton<MediaQueryRepo>(MediaQueryRepo());
  GetIt.I.registerSingleton<LastActivityRepo>(LastActivityRepo());
  GetIt.I.registerSingleton<LiveLocationRepo>(LiveLocationRepo());

  if (isLinux() || isWindows()) {
    // DartVLC.initialize();
    GetIt.I.registerSingleton<AudioPlayerModule>(VlcAudioPlayer());
  } else {
    GetIt.I.registerSingleton<AudioPlayerModule>(NormalAudioPlayer());
  }
  try {
    GetIt.I.registerSingleton<AudioService>(AudioService());
  } catch (_) {}

  if (kIsWeb) {
    GetIt.I.registerSingleton<Notifier>(WebNotifier());
  } else if (isMacOS()) {
    GetIt.I.registerSingleton<Notifier>(MacOSNotifier());
  } else if (isAndroid()) {
    GetIt.I.registerSingleton<Notifier>(AndroidNotifier());
  } else if (isIOS()) {
    GetIt.I.registerSingleton<Notifier>(IOSNotifier());
  } else if (isLinux()) {
    GetIt.I.registerSingleton<Notifier>(LinuxNotifier());
  } else if (isWindows()) {
    GetIt.I.registerSingleton<Notifier>(WindowsNotifier());
  } else {
    GetIt.I.registerSingleton<Notifier>(FakeNotifier());
  }

  GetIt.I.registerSingleton<NotificationServices>(NotificationServices());

  GetIt.I.registerSingleton<CallService>(CallService());

  GetIt.I.registerSingleton<CoreServices>(CoreServices());
  GetIt.I.registerSingleton<FireBaseServices>(FireBaseServices());

  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
  GetIt.I.registerSingleton<RawKeyboardService>(RawKeyboardService());

  GetIt.I.registerSingleton<CallRepo>(CallRepo());
}

Future setupFlutterNotification() async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger().i("Application has been started.");

  if (isDesktop() && !kIsWeb) {
    try {
      _setWindowSize();

      setWindowTitle(APPLICATION_NAME);
    } catch (e) {
      Logger().e(e);
    }
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

_setWindowSize() {
  setWindowMinSize(const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100));
}

class MyApp extends StatelessWidget {
  final _uxService = GetIt.I.get<UxService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MergeStream([
        _uxService.themeStream,
        _i18n.localeStream,
      ]),
      builder: (ctx, snapshot) {
        return ExtraTheme(
          extraThemeData: _uxService.extraTheme,
          child: Focus(
              focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
              onKey: (_, RawKeyEvent event) {
                _rawKeyboardService.escapeHandling(event);
                _rawKeyboardService.searchHandling(event: event);
                return event.physicalKey == PhysicalKeyboardKey.shiftRight
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              },
              child: WithForegroundTask(
                child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Deliver',
                locale: _i18n.locale,
                theme: _uxService.theme,
                navigatorKey: _routingService.mainNavigatorState,
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('fa', 'IR')
                ],
                localizationsDelegates: [
                  I18N.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                home: const SplashScreen(),
                localeResolutionCallback: (deviceLocale, supportedLocale) {
                  for (var locale in supportedLocale) {
                    if (locale.languageCode == deviceLocale!.languageCode &&
                        locale.countryCode == deviceLocale.countryCode) {
                      return deviceLocale;
                    }
                  }
                  return supportedLocale.first;
                },
                builder: (x, c) => Directionality(
                  textDirection: TextDirection.ltr,
                  child: c!,
                ),
              ))),
        );
      },
    );
  }
}
