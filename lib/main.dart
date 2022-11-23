
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
import 'package:deliver/box/dao/file_dao.dart';
import 'package:deliver/box/dao/last_activity_dao.dart';
import 'package:deliver/box/dao/live_location_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/file_info.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/livelocation.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/pending_message.dart';
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
import 'package:deliver/services/drag_and_drop_service.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/log.dart';
import 'package:deliver/services/message_extractor_services.dart';
import 'package:deliver/services/muc_services.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/firebase_options.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:telephony/telephony.dart';
import 'package:window_size/window_size.dart';
import 'box/dao/contact_dao.dart';
import 'box/dao/current_call_dao.dart';
import 'box/dao/custom_notification_dao.dart';
import 'box/dao/media_dao.dart';
import 'box/dao/media_meta_data_dao.dart';
import 'box/dao/message_dao.dart';
import 'box/dao/muc_dao.dart';
import 'box/media.dart';
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
  registerSingleton<RoutingService>(RoutingService());
  registerSingleton<AuthRepo>(AuthRepo());
  registerSingleton<FeatureFlags>(FeatureFlags());
  await GetIt.I.get<AuthRepo>().setCurrentUserUid();
  registerSingleton<DeliverClientInterceptor>(DeliverClientInterceptor());
  await GetIt.I.get<ServicesDiscoveryRepo>().initRepoWithCustomIp();

  //call Service should be here
  registerSingleton<CallService>(CallService());
  registerSingleton<AccountRepo>(AccountRepo());

  registerSingleton<CheckPermissionsService>(CheckPermissionsService());
  registerSingleton<UxService>(UxService());
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
  registerSingleton<MediaRepo>(MediaRepo());
  registerSingleton<LastActivityRepo>(LastActivityRepo());
  registerSingleton<LiveLocationRepo>(LiveLocationRepo());
  registerSingleton<CachingRepo>(CachingRepo());

  try {
    registerSingleton<AudioService>(AudioService());
  } catch (_) {}

  if (isWeb) {
    registerSingleton<Notifier>(WebNotifier());
  } else if (isMacOS) {
    registerSingleton<Notifier>(MacOSNotifier());
  } else if (isAndroid) {
    registerSingleton<Notifier>(AndroidNotifier());
  } else if (isIOS) {
    registerSingleton<Notifier>(IOSNotifier());
  } else if (isLinux) {
    registerSingleton<Notifier>(LinuxNotifier());
  } else if (isWindows) {
    registerSingleton<Notifier>(WindowsNotifier());
  } else {
    registerSingleton<Notifier>(FakeNotifier());
  }

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
}

Future<void> dbSetupDI() async {
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
    ..registerAdapter(MediaAdapter())
    ..registerAdapter(MediaMetaDataAdapter())
    ..registerAdapter(MediaTypeAdapter())
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
    ..registerAdapter(ShowCaseAdapter());

  registerSingleton<CustomNotificationDao>(CustomNotificationDaoImpl());
  registerSingleton<AccountDao>(AccountDaoImpl());
  registerSingleton<AvatarDao>(AvatarDaoImpl());
  registerSingleton<LastActivityDao>(LastActivityDaoImpl());
  registerSingleton<SharedDao>(SharedDaoImpl());
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
  registerSingleton<MediaDao>(MediaDaoImpl());
  registerSingleton<MediaMetaDataDao>(MediaMetaDataDaoImpl());
  registerSingleton<DBManager>(DBManager());
  registerSingleton<LiveLocationDao>(LiveLocationDaoImpl());
  registerSingleton<CallInfoDao>(CallInfoDaoImpl());
  registerSingleton<AutoDownloadDao>(AutoDownloadDaoImpl());
  registerSingleton<CurrentCallInfoDao>(CurrentCallInfoDaoImpl());
  registerSingleton<ActiveNotificationDao>(ActiveNotificationDaoImpl());
  registerSingleton<ShowCaseDao>(ShowCaseDaoImpl());
}

Future initializeFirebase() async {
  await Firebase.initializeApp(
    name: APPLICATION_NAME,
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(SmsMessage message) async {
  print("back sms" + (message.body ?? "body"));
}

// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   print("starttttttt");
//   PhoneState.phoneStateStream.listen((event) {
//     print("incoming call");
//   });
//   // BackgroundFetch.finish(taskId);
// }

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  // PhoneState.phoneStateStream.listen((event) {
  //   print("incoming call");
  // });
  // Workmanager().executeTask((task, inputData) async {
  //   try {} catch (e) {}
  //   try {
  //     // print("start task");
  //     // try{
  //     //   Telephony.backgroundInstance.listenIncomingSms(
  //     //     onNewMessage: (ed) => {
  //     //       print("mmessae"),
  //     //     },
  //     //     // onBackgroundMessage: backgroundMessageHandler,
  //     //   );
  //     // }catch(e){
  //     //   print("message exp");
  //     // }c
  //     // PhoneState.phoneStateStream.listen((event) {
  //     //   print("incoming call");
  //     // });
  //     return false;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //
  //   // switch (task) {
  //   //   case "updating":
  //   //     print("update message ---");
  //   //     break;
  //   //   case "simple":
  //   //   // Telephony.backgroundInstance.listenIncomingSms(
  //   //   //   onNewMessage: (ed) => {
  //   //   //     print("mmessahe"),
  //   //   //   },
  //   //   //   onBackgroundMessage: (e) => {print("bakc msg")},
  //   //   // );
  //   //   // PhoneState.phoneStateStream.listen((event) {
  //   //   //   print("incoming call");
  //   //   // });
  //   // }
  //   return Future.value(false);
  // });
}

init() async {
  // await Permission.phone.request();
  final Telephony telephony = Telephony.instance;
  await telephony.requestPhonePermissions;
  await telephony.requestSmsPermissions;
  telephony.listenIncomingSms(
    onBackgroundMessage: backgroundMessageHandler,
    onNewMessage: (SmsMessage message) {
      print("new message" + (message.body ?? ""));
    },
  );
  // FlutterIncomingCall.configure(
  //     appName: 'example_incoming_call',
  //     duration: 30000,
  //     android: ConfigAndroid(
  //       vibration: true,
  //       ringtonePath: 'default',
  //       channelId: 'calls',
  //       channelName: 'Calls channel name',
  //       channelDescription: 'Calls channel description',
  //     ),
  //     ios: ConfigIOS(
  //       iconName: 'AppIcon40x40',
  //       ringtonePath: null,
  //       includesCallsInRecents: false,
  //       supportsVideo: true,
  //       maximumCallGroups: 2,
  //       maximumCallsPerCallGroup: 1,
  //     )
  // );

  // Workmanager().initialize(
  //   callbackDispatcher, // The top level function, aka callbackDispatcher
  //   //     true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  // );
  // Workmanager().registerOneOffTask("simple", "simple");
  // Workmanager().registerPeriodicTask("simple", "simple");

}

// ignore: avoid_void_async
void main() async {
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();
  init();
  logger.i("Application has been started.");

  if (hasFirebaseCapability) {
    await initializeFirebase();
  }

  logger.i("OS based setups done.");

  try {
    await setupDI();
  } catch (e) {
    logger.e(e);
  }

  logger.i("Dependency Injection setup done.");

  if (isDesktop && !isWeb) {
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
  final sharedDao = GetIt.I.get<SharedDao>();
  final size = await sharedDao.get(SHARED_DAO_WINDOWS_SIZE);
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

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MergeStream([
        _uxService.themeIndexStream,
        _uxService.patternIndexStream,
        _uxService.themeIsDarkStream,
        _uxService.showColorfulStream,
        _i18n.localeStream,
      ]),
      builder: (ctx, snapshot) {
        return ExtraTheme(
          extraThemeData: _uxService.extraTheme,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  _uxService.themeIsDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  _uxService.theme.colorScheme.onInverseSurface,
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
        );
      },
    );
  }
}
