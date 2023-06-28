import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:dart_vlc/dart_vlc.dart'
    if (dart.library.html) 'package:deliver/web_classes/dart_vlc.dart';
import 'package:deliver/box/active_notification.dart';
import 'package:deliver/box/announcement.dart';
import 'package:deliver/box/auto_download.dart';
import 'package:deliver/box/auto_download_room_category.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/broadcast_message_status_type.dart';
import 'package:deliver/box/broadcast_status.dart';
import 'package:deliver/box/broadcast_success_and_failed_count.dart';
import 'package:deliver/box/call_data_usage.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/dao/account_dao.dart';
import 'package:deliver/box/dao/active_notification_dao.dart';
import 'package:deliver/box/dao/announcement_dao.dart';
import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/broadcast_dao.dart';
import 'package:deliver/box/dao/call_data_usage_dao.dart';
import 'package:deliver/box/dao/contact_dao.dart';
import 'package:deliver/box/dao/custom_notification_dao.dart';
import 'package:deliver/box/dao/emoji_skin_tone_dao.dart';
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/dao/is_verified_dao.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/live_location_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/meta_count_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/pending_message_dao.dart';
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
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/livelocation.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/recent_emoji.dart';
import 'package:deliver/box/recent_rooms.dart';
import 'package:deliver/box/recent_search.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/cache/file_cache.dart';
import 'package:deliver/hive/avatar_hive.dart';
import 'package:deliver/hive/contact_hive.dart';
import 'package:deliver/hive/current_call_info_hive.dart';
import 'package:deliver/hive/file_info_hive.dart';
import 'package:deliver/hive/is_verified_hive.dart';
import 'package:deliver/hive/last_call_status_hive.dart';
import 'package:deliver/hive/member_hive.dart';
import 'package:deliver/hive/message_hive.dart';
import 'package:deliver/hive/muc_hive.dart';
import 'package:deliver/hive/pending_message_hive.dart';
import 'package:deliver/hive/room_hive.dart';
import 'package:deliver/hive/uid_id_name_hive.dart';
import 'package:deliver/isar/dao/avatar_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/avatar_hive_dao.dart';
import 'package:deliver/isar/dao/contact_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/contact_hive_dao.dart';
import 'package:deliver/isar/dao/current_call_dao_isar.dart'
    if (dart.library.html) 'package:deliver/hive/dao/current_call_dao_hive.dart';
import 'package:deliver/isar/dao/file_info_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/file_info_hive_dao.dart';
import 'package:deliver/isar/dao/is_verified_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/is_verified_hive_dao.dart';
import 'package:deliver/isar/dao/last_call_status_dao_isar.dart'
    if (dart.library.html) 'package:deliver/hive/dao/last_call_status_dao_hive.dart';
import 'package:deliver/isar/dao/message_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/message_hive_dao.dart';
import 'package:deliver/isar/dao/muc_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/muc_hive_dao.dart';
import 'package:deliver/isar/dao/pending_message_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/pending_message_hive_dao.dart';
import 'package:deliver/isar/dao/room_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/room_hive_dao.dart';
import 'package:deliver/isar/dao/uid_id_name_isar_dao.dart'
    if (dart.library.html) 'package:deliver/hive/dao/uid_id_name_hive_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/window_frame.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/announcement_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/repository/show_case_repo.dart';
import 'package:deliver/repository/stickerRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/screen/lock/lock.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/audio_auto_play_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/background_service.dart';
import 'package:deliver/services/broadcast_service.dart';
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
import 'package:deliver/services/storage_path_service.dart';
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
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart';
import 'package:window_size/window_size.dart';

T registerSingleton<T extends Object>(T instance) {
  if (!GetIt.I.isRegistered<T>()) {
    GetIt.I.registerSingleton<T>(instance);
    return instance;
  } else {
    return GetIt.I.get<T>();
  }
}

Future<void> setupDI() async {
  registerSingleton<CachingRepo>(CachingRepo());

  await dbSetupDI();

  // Setup Logger
  registerSingleton<DeliverLogFilter>(DeliverLogFilter());
  registerSingleton<DeliverLogOutput>(DeliverLogOutput());

  final logger = registerSingleton<Logger>(
    Logger(
      filter: GetIt.I.get<DeliverLogFilter>(),
      level: kDebugMode ? Level.info : Level.nothing,
      output: GetIt.I.get<DeliverLogOutput>(),
    ),
  )..i("db and log initialized");

  registerSingleton<ServicesDiscoveryRepo>(ServicesDiscoveryRepo());

  registerSingleton<I18N>(I18N());

  // Order is important, don't change it!
  registerSingleton<AuthRepo>(AuthRepo());
  registerSingleton<RoutingService>(RoutingService());
  registerSingleton<FeatureFlags>(FeatureFlags());
  registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());

  await GetIt.I.get<AuthRepo>().init();
  logger.i("Auth repo init successfully");
  //call Service should be here
  registerSingleton<CallService>(CallService());
  registerSingleton<EventService>(EventService());
  registerSingleton<AccountRepo>(AccountRepo());
  registerSingleton<ContactRepo>(ContactRepo());
  await GetIt.I.get<AccountRepo>().checkUpdatePlatformSessionInformation();

  registerSingleton<FileService>(FileService());
  registerSingleton<MucServices>(MucServices());
  registerSingleton<CreateMucService>(CreateMucService());
  registerSingleton<NotificationForegroundService>(
    NotificationForegroundService(),
  );

  registerSingleton<BotRepo>(BotRepo());
  registerSingleton<StickerRepo>(StickerRepo());
  registerSingleton<FileInfoCache>(FileInfoCache());
  registerSingleton<FileRepo>(FileRepo());
  registerSingleton<AvatarRepo>(AvatarRepo());
  registerSingleton<MucRepo>(MucRepo());
  registerSingleton<MucHelperService>(MucHelperService());
  registerSingleton<RoomRepo>(RoomRepo());
  registerSingleton<MetaRepo>(MetaRepo());
  registerSingleton<LastActivityRepo>(LastActivityRepo());
  registerSingleton<LiveLocationRepo>(LiveLocationRepo());

  registerSingleton<BroadcastService>(BroadcastService());

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
  registerSingleton<AnnouncementRepo>(AnnouncementRepo());
  registerSingleton<DragAndDropService>(DragAndDropService());
  registerSingleton<PersistentEventHandlerService>(
    PersistentEventHandlerService(),
  );
  registerSingleton<BackgroundService>(BackgroundService());
  if (isMobileNative) {
    registerSingleton<CameraService>(MobileCameraService());
  }

  logger.i("DI setup done successfully");
}

Future<void> dbSetupDI() async {
  registerSingleton<AnalyticsService>(AnalyticsService());
  registerSingleton<AnalyticsRepo>(AnalyticsRepo());
  registerSingleton<AnalyticsClientInterceptor>(AnalyticsClientInterceptor());

  //setup Permission check and StoragePath Service
  registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  registerSingleton<StoragePathService>(StoragePathService());

  try {
    await Hive.initFlutter("$APPLICATION_FOLDER_NAME/db");
  } catch (e) {
    if (kDebugMode) {
      print("hive init error $e");
    }
  }

  Hive
    ..registerAdapter(LastActivityAdapter())
    ..registerAdapter(ContactHiveAdapter())
    ..registerAdapter(UidIdNameHiveAdapter())
    ..registerAdapter(SeenAdapter())
    ..registerAdapter(MucHiveAdapter())
    ..registerAdapter(MucRoleAdapter())
    ..registerAdapter(MemberHiveAdapter())
    ..registerAdapter(BotInfoAdapter())
    ..registerAdapter(RoomHiveAdapter())
    ..registerAdapter(MessageHiveAdapter())
    ..registerAdapter(MessageBriefAdapter())
    ..registerAdapter(MessageTypeAdapter())
    ..registerAdapter(SendingStatusAdapter())
    ..registerAdapter(AvatarHiveAdapter())
    ..registerAdapter(FileInfoHiveAdapter())
    ..registerAdapter(MetaAdapter())
    ..registerAdapter(MetaCountAdapter())
    ..registerAdapter(MetaTypeAdapter())
    ..registerAdapter(LiveLocationAdapter())
    ..registerAdapter(PendingMessageHiveAdapter())
    ..registerAdapter(CallStatusAdapter())
    ..registerAdapter(CallTypeAdapter())
    ..registerAdapter(AutoDownloadRoomCategoryAdapter())
    ..registerAdapter(MucTypeAdapter())
    ..registerAdapter(AutoDownloadAdapter())
    ..registerAdapter(BoxInfoAdapter())
    ..registerAdapter(IsVerifiedHiveAdapter())
    ..registerAdapter(ActiveNotificationAdapter())
    ..registerAdapter(ShowCaseAdapter())
    ..registerAdapter(AnnouncementsAdapter())
    ..registerAdapter(RecentEmojiAdapter())
    ..registerAdapter(EmojiSkinToneAdapter())
    ..registerAdapter(RecentRoomsAdapter())
    ..registerAdapter(RecentSearchAdapter())
    ..registerAdapter(CallDataUsageAdapter())
    ..registerAdapter(BroadcastStatusAdapter())
    ..registerAdapter(BroadcastMessageStatusTypeAdapter())
    ..registerAdapter(BroadcastSuccessAndFailedCountAdapter())
    ..registerAdapter(CurrentCallInfoHiveAdapter())
    ..registerAdapter(LastCallStatusHiveAdapter());

  registerSingleton<CustomNotificationDao>(CustomNotificationDaoImpl());
  registerSingleton<AccountDao>(AccountDaoImpl());
  registerSingleton<AvatarDao>(AvatarDaoImpl());
  registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  registerSingleton<SharedDao>(SharedDaoImpl());
  registerSingleton<ScrollPositionDao>(ScrollPositionDaoImpl());
  registerSingleton<UidIdNameDao>(UidIdNameDaoImpl());
  registerSingleton<SeenDao>(SeenDaoImpl());
  registerSingleton<FileDao>(FileInfoDaoImpl());
  registerSingleton<BlockDao>(BlockDaoImpl());
  registerSingleton<MuteDao>(MuteDaoImpl());
  registerSingleton<MucDao>(MucDaoImpl());
  registerSingleton<BotDao>(BotDaoImpl());
  registerSingleton<ContactDao>(ContactDaoImpl());
  registerSingleton<PendingMessageDao>(PendingMessageDaoImpl());
  registerSingleton<MessageDao>(MessageDaoImpl());
  registerSingleton<RoomDao>(RoomDaoImpl());
  registerSingleton<MetaDao>(MetaDaoImpl());
  registerSingleton<MetaCountDao>(MetaCountDaoImpl());
  registerSingleton<DBManager>(DBManager());
  registerSingleton<LiveLocationDao>(LiveLocationDaoImpl());
  registerSingleton<AutoDownloadDao>(AutoDownloadDaoImpl());
  registerSingleton<CurrentCallInfoDao>(CurrentCallInfoDaoImpl());
  registerSingleton<LastCallStatusDao>(LastCallStatusDaoImpl());
  registerSingleton<ActiveNotificationDao>(ActiveNotificationDaoImpl());
  registerSingleton<ShowCaseDao>(ShowCaseDaoImpl());
  registerSingleton<AnnouncementDao>(AnnouncementDaoImpl());
  registerSingleton<RecentEmojiDao>(RecentEmojiImpl());
  registerSingleton<EmojiSkinToneDao>(EmojiSkinToneImpl());
  registerSingleton<RecentSearchDao>(RecentSearchDaoImpl());
  registerSingleton<RecentRoomsDao>(RecentRoomsDaoImpl());
  registerSingleton<RegisteredBotDao>(RegisteredBotDaoImpl());
  registerSingleton<CallDataUsageDao>(CallDataUsageDaoImpl());
  registerSingleton<BroadcastDao>(BroadcastDaoImpl());
  registerSingleton<CurrentCallInfoDao>(CurrentCallInfoDaoImpl());
  registerSingleton<LastCallStatusDao>(LastCallStatusDaoImpl());

  registerSingleton<IsVerifiedDao>(IsVerifiedDaoImpl());
  await Settings.init();
  registerSingleton<Settings>(Settings());
}

Future initializeFirebase() async {
  if (hasFirebaseCapability) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: isAndroidNative ? APPLICATION_NAME : null,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Pass all uncaught errors from the framework to Crashlytics.
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      // Force enable crashlytics collection enabled if we're testing it.
      // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }
}

// Ignore for this specific time variable
// ignore: avoid-global-state
int AppStartTime = 0;

// There is an exceptional for main function
// ignore: avoid_void_async
void main() async {
  AppStartTime = clock.now().millisecondsSinceEpoch;

  if (isWindowsNative || isLinuxNative) {
    DartVLC.initialize();
  }
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();

  if (isDesktopNative) {
    setWindowTitle(APPLICATION_NAME);

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return true;
    });
  }

  logger.i("Application has been started.");

  await initializeFirebase();

  if (isWeb) {
    document.onContextMenu.listen((e) => e.preventDefault());
  }

  Paint.enableDithering = true;
  runApp(
    const FeatureDiscovery.withProvider(
      persistenceProvider: NoPersistenceProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _animating = BehaviorSubject.seeded(true);
  final _initiating = BehaviorSubject.seeded(true);
  late final Stream<bool> _loading = MergeStream([_initiating, _animating])
      .shareValueSeeded(true)
      .map((event) => _initiating.value || _animating.value)
      .distinct();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: true,
      stream: _loading,
      builder: (c, loadingSnapshot) {
        if (loadingSnapshot.data ?? true) {
          return buildLoading();
        }

        // App now initialized and can be configure
        settings.updateAppContext(context);

        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: onWindowSizeChange,
          child: SizeChangedLayoutNotifier(
            child: StreamBuilder(
              stream: MergeStream([
                settings.themeColorIndex.stream,
                settings.backgroundPatternIndex.stream,
                settings.themeIsDark.stream,
                settings.showColorfulMessages.stream,
                settings.textScale.stream,
                GetIt.I.get<AppLifecycleService>().lifecycleStream,
                GetIt.I.get<I18N>().localeStream,
              ]),
              builder: (ctx, snapshot) {
                return Directionality(
                  textDirection: GetIt.I.get<I18N>().defaultTextDirection,
                  child: ExtraTheme(
                    extraThemeData: settings.extraThemeData,
                    child: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarIconBrightness: settings.brightnessOpposite,
                        systemNavigationBarColor:
                            settings.themeData.colorScheme.onInverseSurface,
                        systemNavigationBarIconBrightness:
                            settings.brightnessOpposite,
                      ),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(
                          skipTraversal: true,
                          canRequestFocus: false,
                        ),
                        onKey: (event) {
                          GetIt.I.get<RawKeyboardService>()
                            ..escapeHandling(event)
                            ..searchHandling(event);
                        },
                        child: MaterialApp(
                          debugShowCheckedModeBanner: false,
                          title: APPLICATION_NAME,
                          onGenerateRoute: (_) {
                            return MaterialPageRoute(
                              builder: (context) {
                                settings.updateAppContext(context);

                                final authRepo = GetIt.I.get<AuthRepo>();

                                if (authRepo.isLocalLockEnabled()) {
                                  return const LockPage();
                                }
                                if (authRepo.isLoggedIn()) {
                                  return const HomePage();
                                }
                                return const IntroPage();
                              },
                            );
                          },
                          locale: GetIt.I.get<I18N>().locale,
                          theme: settings.themeData,
                          navigatorKey:
                              GetIt.I.get<RoutingService>().mainNavigatorState,
                          supportedLocales:
                              Language.values.map((e) => e.locale),
                          localizationsDelegates: [
                            I18N.delegate,
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate
                          ],
                          // home: const SplashScreen(),
                          localeResolutionCallback:
                              (deviceLocale, supportedLocale) {
                            for (final locale in supportedLocale) {
                              if (locale.languageCode ==
                                      deviceLocale!.languageCode &&
                                  locale.countryCode ==
                                      deviceLocale.countryCode) {
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
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _setWindowSize() async {
    setWindowMinSize(
      WindowFrame.minSize.toSize(),
    );

    final windowFrame = settings.windowsFrame.value;
    var rect = windowFrame.toRect();
    if (windowFrame == WindowFrame.empty) {
      final currentScreen = await getCurrentScreen();
      rect =
          currentScreen?.visibleFrame ?? WindowFrame.defaultInstance.toRect();
    }

    try {
      setWindowFrame(rect);
    } catch (e) {
      setWindowMinSize(
        WindowFrame.minSize.toSize(),
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

  Future<void> _init() async {
    await setupDI();

    // Init anyway after some time - no more than 2 seconds
    Timer(const Duration(seconds: 2000), () {
      _animating.add(false);
      _initiating.add(false);
    });

    try {
      if (isDesktopNative) {
        unawaited(_setWindowSize());
      }
    } catch (_) {}

    // Initiating is done
    _initiating.add(false);
  }

  MaterialApp buildLoading() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return Container(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                width: min(220, MediaQuery.of(context).size.width * 0.4),
                height: min(220, MediaQuery.of(context).size.height * 0.4),
                child: RiveAnimation.asset(
                  'assets/animations/intro.riv',
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool onWindowSizeChange(SizeChangedLayoutNotification notification) {
    if (isDesktopNative) {
      getWindowInfo().then((size) {
        settings.windowsFrame.set(
          WindowFrame(
            left: size.frame.left,
            top: size.frame.top,
            right: size.frame.right,
            bottom: size.frame.bottom,
          ),
        );
      });
    }
    return true;
  }

  void _onRiveInit(Artboard artBoard) {
    final controller = StateMachineController(artBoard.stateMachines.first);

    controller.isActiveChanged.addListener(() async {
      if (!controller.isActive) {
        // Animating is done
        _animating.add(false);
      }
    });

    artBoard.addController(controller);
  }
}
