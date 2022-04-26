import 'package:deliver/box/auto_download.dart';
import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/account.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/call_event.dart';
import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/box/dao/account_dao.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/call_info_dao.dart';
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
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
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
import 'package:deliver/services/data_stream_services.dart';
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
import 'package:feature_discovery/feature_discovery.dart';
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
import 'box/dao/custom_notification_dao.dart';
import 'box/dao/media_dao.dart';
import 'box/dao/media_meta_data_dao.dart';
import 'box/dao/message_dao.dart';
import 'box/dao/muc_dao.dart';
import 'box/media.dart';
import 'repository/mucRepo.dart';

Future<void> setupDI() async {
  GetIt.I.registerSingleton<AnalyticsRepo>(AnalyticsRepo());
  GetIt.I.registerSingleton<AnalyticsClientInterceptor>(
    AnalyticsClientInterceptor(),
  );

  // Setup Logger
  GetIt.I.registerSingleton<DeliverLogFilter>(DeliverLogFilter());
  GetIt.I.registerSingleton<Logger>(
    Logger(
      filter: GetIt.I.get<DeliverLogFilter>(),
      level: kDebugMode ? Level.info : Level.nothing,
    ),
  );

  await Hive.initFlutter("db");

  Hive
    ..registerAdapter(AvatarAdapter())
    ..registerAdapter(AccountAdapter())
    ..registerAdapter(LastActivityAdapter())
    ..registerAdapter(ContactAdapter())
    ..registerAdapter(UidIdNameAdapter())
    ..registerAdapter(SeenAdapter())
    ..registerAdapter(FileInfoAdapter())
    ..registerAdapter(MucAdapter())
    ..registerAdapter(MucRoleAdapter())
    ..registerAdapter(MemberAdapter())
    ..registerAdapter(BotInfoAdapter())
    ..registerAdapter(RoomAdapter())
    ..registerAdapter(PendingMessageAdapter())
    ..registerAdapter(MessageAdapter())
    ..registerAdapter(MessageTypeAdapter())
    ..registerAdapter(SendingStatusAdapter())
    ..registerAdapter(MediaAdapter())
    ..registerAdapter(MediaMetaDataAdapter())
    ..registerAdapter(MediaTypeAdapter())
    ..registerAdapter(LiveLocationAdapter())
    ..registerAdapter(CallInfoAdapter())
    ..registerAdapter(CallEventAdapter())
    ..registerAdapter(CallStatusAdapter())
    ..registerAdapter(CallTypeAdapter())
    ..registerAdapter(AutoDownloadRoomCategoryAdapter())
    ..registerAdapter(AutoDownloadAdapter());

  GetIt.I.registerSingleton<CustomNotificationDao>(CustomNotificationDaoImpl());
  GetIt.I.registerSingleton<AccountDao>(AccountDaoImpl());
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
  GetIt.I.registerSingleton<CallInfoDao>(CallInfoDaoImpl());
  GetIt.I.registerSingleton<AutoDownloadDao>(AutoDownloadDaoImpl());

  GetIt.I.registerSingleton<I18N>(I18N());

  // Order is important, don't change it!
  GetIt.I.registerSingleton<AuthServiceClient>(
    AuthServiceClient(
      isWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
    ),
  );
  GetIt.I.registerSingleton<RoutingService>(RoutingService());
  final authRepo = AuthRepo();
  GetIt.I.registerSingleton<AuthRepo>(authRepo);
  await authRepo.setCurrentUserUid();
  GetIt.I
      .registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());

  final grpcClientInterceptors = [
    GetIt.I.get<DeliverClientInterceptor>(),
    GetIt.I.get<AnalyticsClientInterceptor>()
  ];

  GetIt.I.registerSingleton<UserServiceClient>(
    UserServiceClient(
      isWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<ContactServiceClient>(
    ContactServiceClient(
      isWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<QueryServiceClient>(
    QueryServiceClient(
      isWeb ? webQueryClientChannel : QueryClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<CoreServiceClient>(
    CoreServiceClient(
      isWeb ? webCoreServicesClientChannel : CoreServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<BotServiceClient>(
    BotServiceClient(
      isWeb ? webBotClientChannel : BotClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<StickerServiceClient>(
    StickerServiceClient(
      isWeb ? webStickerClientChannel : StickerClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<GroupServiceClient>(
    GroupServiceClient(
      isWeb ? webMucServicesClientChannel : MucServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<ChannelServiceClient>(
    ChannelServiceClient(
      isWeb ? webMucServicesClientChannel : MucServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<AvatarServiceClient>(
    AvatarServiceClient(
      isWeb ? webAvatarServicesClientChannel : AvatarServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<FirebaseServiceClient>(
    FirebaseServiceClient(
      isWeb ? webFirebaseServicesClientChannel : FirebaseServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );

  GetIt.I.registerSingleton<SessionServiceClient>(
    SessionServiceClient(
      isWeb ? webProfileServicesClientChannel : ProfileServicesClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
  GetIt.I.registerSingleton<LiveLocationServiceClient>(
    LiveLocationServiceClient(
      isWeb ? webLiveLocationClientChannel : LiveLocationServiceClientChannel,
      interceptors: grpcClientInterceptors,
    ),
  );
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
  GetIt.I.registerSingleton<MediaRepo>(MediaRepo());
  GetIt.I.registerSingleton<LastActivityRepo>(LastActivityRepo());
  GetIt.I.registerSingleton<LiveLocationRepo>(LiveLocationRepo());

  if (isLinux || isWindows) {
    // DartVLC.initialize();
    GetIt.I.registerSingleton<AudioPlayerModule>(VlcAudioPlayer());
  } else {
    GetIt.I.registerSingleton<AudioPlayerModule>(NormalAudioPlayer());
  }
  try {
    GetIt.I.registerSingleton<AudioService>(AudioService());
  } catch (_) {}

  if (isWeb) {
    GetIt.I.registerSingleton<Notifier>(WebNotifier());
  } else if (isMacOS) {
    GetIt.I.registerSingleton<Notifier>(MacOSNotifier());
  } else if (isAndroid) {
    GetIt.I.registerSingleton<Notifier>(AndroidNotifier());
  } else if (isIOS) {
    GetIt.I.registerSingleton<Notifier>(IOSNotifier());
  } else if (isLinux) {
    GetIt.I.registerSingleton<Notifier>(LinuxNotifier());
  } else if (isWindows) {
    GetIt.I.registerSingleton<Notifier>(WindowsNotifier());
  } else {
    GetIt.I.registerSingleton<Notifier>(FakeNotifier());
  }

  GetIt.I.registerSingleton<NotificationServices>(NotificationServices());

  GetIt.I.registerSingleton<CallService>(CallService());

  GetIt.I.registerSingleton<DataStreamServices>(DataStreamServices());
  GetIt.I.registerSingleton<CoreServices>(CoreServices());
  GetIt.I.registerSingleton<FireBaseServices>(FireBaseServices());

  GetIt.I.registerSingleton<MessageRepo>(MessageRepo());
  GetIt.I.registerSingleton<RawKeyboardService>(RawKeyboardService());

  GetIt.I.registerSingleton<CallRepo>(CallRepo());
}

Future initializeFirebase() async {
  await Firebase.initializeApp();
}

// ignore: avoid_void_async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger().i("Application has been started.");

  if (hasFirebaseCapability) {
    await initializeFirebase();
  }

  Logger().i("OS based setups done.");

  try {
    await setupDI();
  } catch (e) {
    Logger().e(e);
  }

  Logger().i("Dependency Injection setup done.");

  if (isDesktop && !isWeb) {
    try {
      await _setWindowSize();

      setWindowTitle(APPLICATION_NAME);
    } catch (e) {
      Logger().e(e);
    }
  }

  runApp(
    FeatureDiscovery.withProvider(
      persistenceProvider: const NoPersistenceProvider(),
      child: MyApp(),
    ),
  );
}

Future<void> _setWindowSize() async {
  final _sharedDao = GetIt.I.get<SharedDao>();
  final size = await _sharedDao.get('SHARED_DAO_WINDOWS_SIZE');
  final rect = size?.split('_');

  if (rect != null) {
    try {
      setWindowFrame(
        Rect.fromLTRB(
          double.parse(rect[0]),
          double.parse(rect[1]),
          double.parse(rect[2]),
          double.parse(rect[3]),
        ),
      );
    } catch (e) {
      setWindowMinSize(
        const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100),
      );
    }
  } else {
    setWindowMinSize(const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100));
  }
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
        _uxService.themeIndexStream,
        _uxService.themeIsDarkStream,
        _i18n.localeStream,
      ]),
      builder: (ctx, snapshot) {
        return ExtraTheme(
          extraThemeData: _uxService.extraTheme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: _uxService.theme.colorScheme.background,
              systemNavigationBarIconBrightness:
                  _uxService.themeIsDark ? Brightness.light : Brightness.dark,
            ),
            child: Focus(
              focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
              onKey: (_, event) {
                _rawKeyboardService
                  ..escapeHandling(event)
                  ..searchHandling(event);
                return event.physicalKey == PhysicalKeyboardKey.shiftRight
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              },
              child: WithForegroundTask(
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: APPLICATION_NAME,
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
                    for (final locale in supportedLocale) {
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
