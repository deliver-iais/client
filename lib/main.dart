import 'package:dart_vlc/dart_vlc.dart'
    if (dart.library.html) 'package:deliver/web_classes/dart_vlc.dart';
import 'package:deliver/box/account.dart';
import 'package:deliver/box/active_notification.dart';
import 'package:deliver/box/auto_download.dart';
import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/call_event.dart';
import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/account_dao.dart';
import 'package:deliver/box/dao/active_notification_dao.dart';
import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/call_info_dao.dart';
import 'package:deliver/box/dao/emoji_skin_tone_dao.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/live_location_dao.dart';
import 'package:deliver/box/dao/meta_count_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/recent_emoji_dao.dart';
import 'package:deliver/box/dao/recent_rooms_dao.dart';
import 'package:deliver/box/dao/recent_search_dao.dart';
import 'package:deliver/box/dao/registered_bot_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/scroll_position_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/emoji_skin_tone.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/livelocation.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/recent_emoji.dart';
import 'package:deliver/box/recent_rooms.dart';
import 'package:deliver/box/recent_search.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/box/show_case.dart';
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

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/repository/stickerRepo.dart';
import 'package:deliver/screen/splash/splash_screen.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/audio_auto_play_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/data_stream_services.dart';
import 'package:deliver/services/drag_and_drop_service.dart';
import 'package:deliver/services/event_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/log.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/persistent_event_handler_service.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/video_player_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/firebase_options.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_size/window_size.dart';

import 'box/dao/contact_dao.dart';
import 'box/dao/current_call_dao.dart';
import 'box/dao/custom_notification_dao.dart';
import 'box/dao/message_dao.dart';
import 'box/dao/muc_dao.dart';
import 'repository/caching_repo.dart';
import 'repository/mucRepo.dart';
import 'repository/show_case_repo.dart';

void registerSingleton<T extends Object>(T instance) {
  if (!GetIt.I.isRegistered<T>()) {
    GetIt.I.registerSingleton<T>(instance);
  }
}

Future<void> setupDI() async {
  await dbSetupDI();

  // Setup Logger
  registerSingleton<DeliverLogFilter>(DeliverLogFilter());
  registerSingleton<DeliverLogOutput>(DeliverLogOutput());
  registerSingleton<Logger>(
    Logger(
      filter: GetIt.I.get<DeliverLogFilter>(),
      level: kDebugMode ? Level.info : Level.nothing,
      output: GetIt.I.get<DeliverLogOutput>(),
    ),
  );

  registerSingleton<ServicesDiscoveryRepo>(ServicesDiscoveryRepo());

  registerSingleton<I18N>(I18N());

  // Order is important, don't change it!
  registerSingleton<AuthRepo>(AuthRepo());
  registerSingleton<RoutingService>(RoutingService());
  registerSingleton<FeatureFlags>(FeatureFlags());
  await GetIt.I.get<AuthRepo>().init(retry: true);
  registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());
  GetIt.I.get<ServicesDiscoveryRepo>().initClientChannels();

  //call Service should be here
  registerSingleton<CallService>(CallService());
  registerSingleton<EventService>(EventService());
  registerSingleton<AccountRepo>(AccountRepo());

  registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  registerSingleton<FileService>(FileService());
  registerSingleton<MucServices>(MucServices());
  registerSingleton<CreateMucService>(CreateMucService());
  registerSingleton<NotificationForegroundService>(
    NotificationForegroundService(),
  );
  registerSingleton<BotRepo>(BotRepo());
  registerSingleton<StickerRepo>(StickerRepo());
  registerSingleton<FileRepo>(FileRepo());
  registerSingleton<ContactRepo>(ContactRepo());
  registerSingleton<AvatarRepo>(AvatarRepo());
  registerSingleton<MucRepo>(MucRepo());
  registerSingleton<RoomRepo>(RoomRepo());
  registerSingleton<MetaRepo>(MetaRepo());
  registerSingleton<LastActivityRepo>(LastActivityRepo());
  registerSingleton<LiveLocationRepo>(LiveLocationRepo());
  registerSingleton<CachingRepo>(CachingRepo());

  try {
    registerSingleton<AudioAutoPlayService>(AudioAutoPlayService());
    registerSingleton<AudioService>(AudioService());
    registerSingleton<VideoPlayerService>(VideoPlayerService());
  } catch (_) {}

  if (isWeb) {
    registerSingleton<Notifier>(WebNotifier());
  } else if (isMacOSNative) {
    registerSingleton<Notifier>(MacOSNotifier());
  } else if (isAndroidNative) {
    registerSingleton<Notifier>(AndroidNotifier());
  } else if (isIOSNative) {
    registerSingleton<Notifier>(IOSNotifier());
  } else if (isLinuxNative) {
    registerSingleton<Notifier>(LinuxNotifier());
  } else if (isWindowsNative) {
    registerSingleton<Notifier>(WindowsNotifier());
  } else {
    registerSingleton<Notifier>(FakeNotifier());
  }
  registerSingleton<AppLifecycleService>(AppLifecycleService());
  registerSingleton<MessageExtractorServices>(MessageExtractorServices());
  registerSingleton<NotificationServices>(NotificationServices());
  registerSingleton<DataStreamServices>(DataStreamServices());
  registerSingleton<CoreServices>(CoreServices());
  registerSingleton<FireBaseServices>(FireBaseServices());

  registerSingleton<MessageRepo>(MessageRepo());
  registerSingleton<RawKeyboardService>(RawKeyboardService());

  registerSingleton<CallRepo>(CallRepo());
  registerSingleton<UrlHandlerService>(UrlHandlerService());
  registerSingleton<ShowCaseRepo>(ShowCaseRepo());
  registerSingleton<DragAndDropService>(DragAndDropService());
  registerSingleton<PersistentEventHandlerService>(
    PersistentEventHandlerService(),
  );
  registerSingleton<BackgroundService>(BackgroundService());
  if (isMobileNative) {
    registerSingleton<CameraService>(MobileCameraService());
  }
}

Future<void> dbSetupDI() async {
  registerSingleton<AnalyticsService>(AnalyticsService());
  registerSingleton<AnalyticsRepo>(AnalyticsRepo());
  registerSingleton<AnalyticsClientInterceptor>(AnalyticsClientInterceptor());

  await Hive.initFlutter("$APPLICATION_FOLDER_NAME/db");

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
    ..registerAdapter(MessageBriefAdapter())
    ..registerAdapter(MessageTypeAdapter())
    ..registerAdapter(SendingStatusAdapter())
    ..registerAdapter(MetaAdapter())
    ..registerAdapter(MetaCountAdapter())
    ..registerAdapter(MetaTypeAdapter())
    ..registerAdapter(LiveLocationAdapter())
    ..registerAdapter(CallInfoAdapter())
    ..registerAdapter(CallEventAdapter())
    ..registerAdapter(CallStatusAdapter())
    ..registerAdapter(CallTypeAdapter())
    ..registerAdapter(AutoDownloadRoomCategoryAdapter())
    ..registerAdapter(CurrentCallInfoAdapter())
    ..registerAdapter(MucTypeAdapter())
    ..registerAdapter(AutoDownloadAdapter())
    ..registerAdapter(BoxInfoAdapter())
    ..registerAdapter(ActiveNotificationAdapter())
    ..registerAdapter(ShowCaseAdapter())
    ..registerAdapter(RecentEmojiAdapter())
    ..registerAdapter(EmojiSkinToneAdapter())
    ..registerAdapter(RecentRoomsAdapter())
    ..registerAdapter(RecentSearchAdapter());

  registerSingleton<CustomNotificationDao>(CustomNotificationDaoImpl());
  registerSingleton<AccountDao>(AccountDaoImpl());
  registerSingleton<AvatarDao>(AvatarDaoImpl());
  registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  registerSingleton<SharedDao>(SharedDaoImpl());
  registerSingleton<ScrollPositionDao>(ScrollPositionDaoImpl());
  registerSingleton<UidIdNameDao>(UidIdNameDaoImpl());
  registerSingleton<SeenDao>(SeenDaoImpl());
  registerSingleton<FileDao>(FileDaoImpl());
  registerSingleton<BlockDao>(BlockDaoImpl());
  registerSingleton<MuteDao>(MuteDaoImpl());
  registerSingleton<MucDao>(MucDaoImpl());
  registerSingleton<BotDao>(BotDaoImpl());
  registerSingleton<ContactDao>(ContactDaoImpl());
  registerSingleton<MessageDao>(MessageDaoImpl());
  registerSingleton<RoomDao>(RoomDaoImpl());
  registerSingleton<MetaDao>(MetaDaoImpl());
  registerSingleton<MetaCountDao>(MetaCountDaoImpl());
  registerSingleton<DBManager>(DBManager());
  registerSingleton<LiveLocationDao>(LiveLocationDaoImpl());
  registerSingleton<CallInfoDao>(CallInfoDaoImpl());
  registerSingleton<AutoDownloadDao>(AutoDownloadDaoImpl());
  registerSingleton<CurrentCallInfoDao>(CurrentCallInfoDaoImpl());
  registerSingleton<ActiveNotificationDao>(ActiveNotificationDaoImpl());
  registerSingleton<ShowCaseDao>(ShowCaseDaoImpl());
  registerSingleton<RecentEmojiDao>(RecentEmojiImpl());
  registerSingleton<EmojiSkinToneDao>(EmojiSkinToneImpl());
  registerSingleton<RecentSearchDao>(RecentSearchDaoImpl());
  registerSingleton<RecentRoomsDao>(RecentRoomsDaoImpl());
  registerSingleton<RegisteredBotDao>(RegisteredBotDaoImpl());

  registerSingleton<Settings>(Settings());

  /// Initiating Settings Variables
  await Future.delayed(const Duration(milliseconds: 500));
}

Future initializeFirebase() async {
  await Firebase.initializeApp(
    name: isAndroidNative ? APPLICATION_NAME : null,
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// ignore: avoid_void_async
void main() async {
  if (isWindowsNative || isLinuxNative) {
    DartVLC.initialize();
  }
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktopDevice) {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return true;
    });
  }

  logger.i("Application has been started.");

  if (hasFirebaseCapability) {
    await initializeFirebase();
    // Pass all uncaught errors from the framework to Crashlytics.
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Force enable crashlytics collection enabled if we're testing it.
    // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  logger.i("OS based setups done.");

  try {
    await setupDI();
  } catch (e) {
    logger.e(e);
  }

  logger.i("Dependency Injection setup done.");

  if (isDesktopNative) {
    try {
      await _setWindowSize();

      setWindowTitle(APPLICATION_NAME);
    } catch (e) {
      logger.e(e);
    }
  }

  Paint.enableDithering = true;
  runApp(
    FeatureDiscovery.withProvider(
      persistenceProvider: const NoPersistenceProvider(),
      child: MyApp(),
    ),
  );
}

Future<void> _setWindowSize() async {
  setWindowMinSize(const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100));
  final windowFrame = settings.windowsFrame.value;

  try {
    setWindowFrame(
      Rect.fromLTRB(
        windowFrame.left,
        windowFrame.top,
        windowFrame.right,
        windowFrame.bottom,
      ),
    );
  } catch (e) {
    setWindowMinSize(
      const Size(FLUID_MAX_WIDTH + 100, FLUID_MAX_HEIGHT + 100),
    );
  }

  // setWindowMaxSize(const Size(3000, 3000));

  // Showcase Creation Values
  // Tablet
  // const width = 1139.0;
  // const height = 755.0;
  // setWindowMinSize(const Size(width, height));
  // setWindowMaxSize(const Size(width, height));
  // setWindowFrame(const Rect.fromLTRB(0, 0, width, height));

  // Mobile
  // const width = 362.0;
  // const height = 688.0;
  // setWindowMinSize(const Size(width, height));
  // setWindowMaxSize(const Size(width, height));
  // setWindowFrame(const Rect.fromLTRB(0, 0, width, height));
}

class MyApp extends StatelessWidget {
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();
  final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    settings.updateMainContext(context);
    return StreamBuilder(
      stream: MergeStream([
        settings.themeColorIndex.stream,
        settings.backgroundPatternIndex.stream,
        settings.themeIsDark.stream,
        settings.showColorfulMessages.stream,
        settings.textScale.stream,
        _appLifecycleService.lifecycleStream,
        _i18n.localeStream,
      ]),
      builder: (ctx, snapshot) {
        return Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: ExtraTheme(
            extraThemeData: settings.extraThemeData,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarIconBrightness: settings.brightnessOpposite,
                systemNavigationBarColor:
                    settings.themeData.colorScheme.onInverseSurface,
                systemNavigationBarIconBrightness: settings.brightnessOpposite,
              ),
              child: RawKeyboardListener(
                focusNode:
                    FocusNode(skipTraversal: true, canRequestFocus: false),
                onKey: (event) {
                  _rawKeyboardService
                    ..escapeHandling(event)
                    ..searchHandling(event);
                },
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: APPLICATION_NAME,
                  locale: _i18n.locale,
                  theme: settings.themeData,
                  navigatorKey: _routingService.mainNavigatorState,
                  supportedLocales: Language.values.map((e) => e.locale),
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
                  // builder: (x, c) => c!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
