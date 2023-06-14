import 'package:deliver/box/account.dart';
import 'package:deliver/models/window_frame.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:rxdart/rxdart.dart';

final settings = GetIt.I.get<Settings>();

class Settings {
  static Future<void> init() async {
    await SharedPreferenceStorage.init();
    await SharedDaoStorage.init();
  }

  final batteryMonitor = PerformanceMonitor.batteryMonitor;
  final performanceMode = PerformanceMonitor.performanceModeSetting;
  final powerSaverBatteryLevel = PerformanceMonitor.powerSaverBatteryLevel;

  final accessToken = StringPersistent(
    SharedKeys.SHARED_DAO_ACCESS_TOKEN_KEY.inSharedPreferenceStorage(),
    defaultValue: "",
  );
  final refreshToken = StringPersistent(
    SharedKeys.SHARED_DAO_REFRESH_TOKEN_KEY.inSharedPreferenceStorage(),
    defaultValue: "",
  );
  final refreshTokenDao = StringPersistent(
    SharedKeys.SHARED_DAO_REFRESH_TOKEN_KEY.inSharedDaoStorage(),
    defaultValue: "",
  );
  final localPassword = StringPersistent(
    SharedKeys.SHARED_DAO_LOCAL_PASSWORD.inSharedPreferenceStorage(),
    defaultValue: "",
  );
  final applicationVersion = StringPersistent(
    SharedKeys.VERSION.inSharedDaoStorage(),
    defaultValue: "",
  );
  final dbHashCode = IntPersistent(
    SharedKeys.SHARED_DAO_DB_VERSION.inSharedDaoStorage(),
    defaultValue: 0,
  );
  final themeColorIndex = IntPersistent(
    SharedKeys.SHARED_DAO_THEME_COLOR.inSharedDaoStorage(),
    defaultValue: 0,
  );
  final backgroundPatternIndex = IntPersistent(
    SharedKeys.SHARED_DAO_THEME_PATTERN.inSharedDaoStorage(),
    defaultValue: 0,
  );
  final lastRoomMetadataUpdateTime = IntPersistent(
    SharedKeys.SHARED_DAO_KEY_LAST_ROOM_METADATA_UPDATE_TIME
        .inSharedDaoStorage(),
    defaultValue: 0,
  );
  final textScale = DoublePersistent(
    SharedKeys.SHARED_DAO_THEME_FONT_SIZE.inSharedDaoStorage(),
    defaultValue: 1.0,
  );
  final navigationPanelSize = DoublePersistent(
    SharedKeys.NAVIGATION_PANEL_SIZE.inMemoryStorage(),
    defaultValue: NAVIGATION_PANEL_MIN_WIDTH,
  );
  final sendByEnter = BooleanPersistent(
    SharedKeys.SHARED_DAO_SEND_BY_ENTER.inSharedDaoStorage(),
    defaultValue: isDesktopDevice,
  );
  final hasProfile = BooleanPersistent(
    SharedKeys.HAS_PROFILE.inSharedDaoStorage(),
    defaultValue: false,
  );
  final allRoomFetched = BooleanPersistent(
    SharedKeys.SHARED_DAO_ALL_ROOMS_FETCHED.inSharedDaoStorage(),
    defaultValue: false,
  );
  final foregroundNotificationIsEnabled = BooleanPersistent(
    SharedKeys.SHARED_DAO_NOTIFICATION_FOREGROUND.inSharedDaoStorage(),
    defaultValue: false,
  );
  final firebaseSettingIsSet = BooleanPersistent(
    SharedKeys.SHARED_DAO_FIREBASE_SETTING_IS_SET.inSharedDaoStorage(),
    defaultValue: false,
  );
  final firebaseToken = StringPersistent(
    SharedKeys.SHARED_DAO_FIREBASE_TOKEN.inSharedDaoStorage(),
    defaultValue: "",
  );
  final windowsFrame = JsonMapPersistent<WindowFrame>(
    SharedKeys.WINDOW_FRAME.inSharedDaoStorage(),
    defaultValue: WindowFrame.empty,
    fromJsonMap: WindowFrameFromJson,
    toJsonMap: WindowFrameToJson,
  );

  final account = JsonMapPersistent<Account>(
    SharedKeys.ACCOUNT.inSharedDaoStorage(),
    defaultValue: Account.empty,
    fromJsonMap: AccountFromJson,
    toJsonMap: AccountToJson,
  );
  final lastMessageDeliveryAck = ProtoPersistent<MessageDeliveryAck>(
    SharedKeys.LAST_MESSAGE_DELIVERY_ACK.inSharedPreferenceStorage(),
    defaultValue: MessageDeliveryAck.getDefault(),
    fromJson: MessageDeliveryAck.fromJson,
  );
  final showTextsJustified = BooleanPersistent(
    SharedKeys.SHARED_DAO_THEME_SHOW_TEXTS_JUSTIFIED.inSharedDaoStorage(),
    defaultValue: false,
  );
  final showColorfulMessages = BooleanPersistent(
    SharedKeys.SHARED_DAO_THEME_SHOW_COLORFUL_MESSAGES.inSharedDaoStorage(),
    defaultValue: false,
  );
  final showEvents = BooleanPersistent(
    SharedKeys.SHARED_DAO_SHOW_EVENTS.inSharedDaoStorage(),
    defaultValue: false,
  );
  final playInChatSounds = BooleanPersistent(
    SharedKeys.SHARED_DAO_THEME_PLAY_IN_CHAT_SOUNDS.inSharedDaoStorage(),
    defaultValue: true,
  );
  final isAllNotificationDisabled = BooleanPersistent(
    SharedKeys.SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED.inSharedDaoStorage(),
    defaultValue: false,
  );
  final isNotificationAdvanceModeDisabled = BooleanPersistent(
    SharedKeys.SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED
        .inSharedDaoStorage(),
    defaultValue: true,
  );
  final isAutoNightModeEnable = BooleanPersistent(
    SharedKeys.SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE.inSharedDaoStorage(),
    defaultValue: true,
  );
  final showDeveloperPage = BooleanPersistent(
    SharedKeys.SHOW_DEVELOPER_PAGE.inSharedDaoStorage(),
    defaultValue: false,
  );
  late final themeIsDark = BooleanPersistent(
    SharedKeys.SHARED_DAO_THEME_IS_DARK.inSharedDaoStorage(),
    defaultValue: isAutoNightModeEnable.value &&
        PlatformDispatcher.instance.platformBrightness == Brightness.dark,
  );
  late final showDeveloperDetails = BooleanPersistent(
    SharedKeys.SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS
        .inMemoryStorage(),
    defaultValue: false,
  );
  final keyboardSizePortrait = DoublePersistent(
    SharedKeys.SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT.inSharedDaoStorage(),
    defaultValue: 0,
  );

  final keyboardSizePortraitInMemory = DoublePersistent(
    SharedKeys.SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT_IN_MEMORY.inMemoryStorage(),
    defaultValue: 0,
  );

  final keyboardSizeLandscape = DoublePersistent(
    SharedKeys.SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE.inSharedDaoStorage(),
    defaultValue: 0,
  );
  final keyboardSizeLandscapeInMemory = DoublePersistent(
    SharedKeys.SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE_IN_MEMORY
        .inSharedDaoStorage(),
    defaultValue: 0,
  );
  final iceCandidateNumbers = IntPersistent(
    SharedKeys.ICE_CANDIDATE_NUMBERS.inSharedDaoStorage(),
    defaultValue: 15,
  );
  final iceCandidateTimeLimit = IntPersistent(
    SharedKeys.ICE_CANDIDATE_TIME_LIMIT.inSharedDaoStorage(),
    defaultValue: 1500,
  );
  final videoFrameRateLimitation = IntPersistent(
    SharedKeys.VIDEO_FRAME_RATE_LIMITATION.inSharedDaoStorage(),
    defaultValue: 30,
  );
  final language = EnumPersistent<Language>(
    SharedKeys.LANGUAGE.inSharedDaoStorage(),
    defaultValue: Language.defaultLanguage,
    enumValues: Language.values,
  );
  final logLevel = EnumPersistent<Level>(
    SharedKeys.LOG_LEVEL.inSharedDaoStorage(),
    defaultValue: kDebugMode ? Level.info : Level.debug,
    enumValues: Level.values,
  );
  final videoCallQuality = EnumPersistent<VideoCallQuality>(
    SharedKeys.VIDEO_CALL_QUALITY.inSharedDaoStorage(),
    defaultValue: VideoCallQuality.MEDIUM,
    enumValues: VideoCallQuality.values,
  );
  final logInFileEnable = BooleanPersistent(
    SharedKeys.LOG_IN_FILE_ENABLE.inSharedDaoStorage(),
    defaultValue: false,
  );
  final useBadCertificateConnection = BooleanPersistent(
    SharedKeys.USE_BAD_CERTIFICATE_CONNECTION.inSharedDaoStorage(),
    defaultValue: false,
  );
  final hostSetByUser = StringPersistent(
    SharedKeys.SHARE_DAO_HOST_SET_BY_USER.inSharedDaoStorage(),
    defaultValue: "",
  );
  final servicesInfo = StringPersistent(
    SharedKeys.SHARE_DAO_SERVICES_INFO.inSharedDaoStorage(),
    defaultValue: "",
  );
  final webViewUrl = StringPersistent(
    SharedKeys.SHARE_DAO_WEB_VIEW_URL.inSharedDaoStorage(),
    defaultValue: "https://bamakkala.ir",
  );
  final onceShowNewVersionInformation = OncePersistent(
    SharedKeys.ONCE_SHOW_NEW_VERSION_INFORMATION.inSharedDaoStorage(),
    count: 50,
    period: const Duration(hours: 2),
  );
  final onceShowContactDialog = OncePersistent(
    SharedKeys.ONCE_SHOW_CONTACT_DIALOG.inSharedDaoStorage(),
    count: 2,
    period: const Duration(hours: 2),
  );
  final onceShowMicrophoneDialog = OncePersistent(
    SharedKeys.ONCE_SHOW_MICROPHONE_DIALOG.inSharedDaoStorage(),
    count: 40,
    period: const Duration(minutes: 15),
  );
  final onceShowCameraDialog = OncePersistent(
    SharedKeys.ONCE_SHOW_CAMERA_DIALOG.inSharedDaoStorage(),
    count: 5,
    period: const Duration(hours: 1),
  );
  final onceShowMediaLibraryDialog = OncePersistent(
    SharedKeys.ONCE_SHOW_MEDIA_LIBRARY_DIALOG.inSharedDaoStorage(),
    count: 10,
    period: const Duration(hours: 1),
  );
  final showLinkPreview = PerformanceBooleanPersistent(
    SharedKeys.SHARED_DAO_THEME_SHOW_LINK_PREVIEW.inSharedDaoStorage(),
    PerformanceMode.POWER_SAVER,
  );
  final repeatAnimatedEmoji = PerformanceBooleanPersistent(
    SharedKeys.REPEAT_ANIMATED_EMOJI.inSharedDaoStorage(),
    PerformanceMode.HIGH,
  );
  final repeatAnimatedStickers = PerformanceBooleanPersistent(
    SharedKeys.REPEAT_ANIMATED_STICKERS.inSharedDaoStorage(),
    PerformanceMode.HIGH,
  );
  final showAnimatedEmoji = PerformanceBooleanPersistent(
    SharedKeys.SHOW_ANIMATED_EMOJI.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showRoomBackground = PerformanceBooleanPersistent(
    SharedKeys.SHOW_ROOM_BACKGROUND.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showBlurredComponents = PerformanceBooleanPersistent(
    SharedKeys.SHOW_BLURRED_COMPONENTS.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showMessageDetails = PerformanceBooleanPersistent(
    SharedKeys.SHOW_MESSAGE_DETAILS.inSharedDaoStorage(),
    PerformanceMode.POWER_SAVER,
  );
  final showAnimations = PerformanceBooleanPersistent(
    SharedKeys.SHOW_ANIMATIONS.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showAnimatedAvatars = PerformanceBooleanPersistent(
    SharedKeys.SHOW_ANIMATED_AVATARS.inSharedDaoStorage(),
    PerformanceMode.HIGH,
  );
  final showAvatarImages = PerformanceBooleanPersistent(
    SharedKeys.SHOW_AVATAR_IMAGES.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showAvatars = PerformanceBooleanPersistent(
    SharedKeys.SHOW_AVATARS.inSharedDaoStorage(),
    PerformanceMode.POWER_SAVER,
  );
  final parseAndShowGoogleEmojis = PerformanceBooleanPersistent(
    SharedKeys.PARSE_AND_SHOW_EMOJIS.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
  );
  final showWsWithHighFrameRate = PerformanceBooleanPersistent(
    SharedKeys.SHOW_WS_WITH_HIGH_FRAME_RATE.inSharedDaoStorage(),
    PerformanceMode.HIGH,
  );
  final showCallBackGroundAnimation = PerformanceBooleanPersistent(
    SharedKeys.SHOW_WS_WITH_HIGH_FRAME_RATE.inSharedDaoStorage(),
    PerformanceMode.HIGH,
  );
  final lowNetworkUsageVideoCall = PerformanceBooleanPersistent(
    SharedKeys.LOW_NETWORK_USAGE_VIDEO_CALL.inSharedDaoStorage(),
    PerformanceMode.POWER_SAVER,
    defaultValue: false,
    isReverse: true,
  );
  final lowNetworkUsageVoiceCall = PerformanceBooleanPersistent(
    SharedKeys.LOW_NETWORK_USAGE_VOICE_CALL.inSharedDaoStorage(),
    PerformanceMode.POWER_SAVER,
    defaultValue: false,
    isReverse: true,
  );
  final highQualityCall = PerformanceBooleanPersistent(
    SharedKeys.HIGH_QUALITY_CALL.inSharedDaoStorage(),
    PerformanceMode.BALANCED,
    defaultValue: false,
  );

  final _appContext = BehaviorSubject<BuildContext?>.seeded(null);

  // StreamSubscription<bool>? _isAllNotificationDisabledSubscribe;

  void reInitialize() {
    // TODO(bitbeter): fix and investigate this
    // _isAllNotificationDisabledSubscribe?.cancel();
  }

  Settings() {
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (isAutoNightModeEnable.value) {
        themeIsDark.set(
          PlatformDispatcher.instance.platformBrightness == Brightness.dark,
        );
      }
    };
  }

  void updateAppContext(BuildContext context) => _appContext.add(context);

  BuildContext get appContext => _appContext.value!;

  Brightness get brightnessOpposite =>
      !themeIsDark.value ? Brightness.dark : Brightness.light;

  ThemeScheme get themeScheme => getThemeScheme(themeColorIndex.value);

  ThemeData get introThemeData => settings.themeScheme
      .theme()
      .copyWith(scaffoldBackgroundColor: INTRO_COLOR_BACKGROUND);

  ThemeData get themeData => themeScheme.theme(isDark: themeIsDark.value);

  ExtraThemeData get extraThemeData =>
      themeScheme.extraTheme(isDark: themeIsDark.value);

  CorePalette get corePalette =>
      CorePalette.of(palettes[themeColorIndex.value % palettes.length].value);
}

class FeatureFlags {
  final _authRepo = GetIt.I.get<AuthRepo>();

  bool labIsAvailable() =>
      _voiceCallFeatureIsPossible() || hasForegroundServiceCapability;

  bool isVoiceCallAvailable() => _voiceCallFeatureIsPossible();

  bool _voiceCallFeatureIsPossible() => !isLinuxDevice;

  bool hasVoiceCallPermission(Uid roomUid) =>
      roomUid.isUser() &&
      !_authRepo.isCurrentUser(roomUid) &&
      isVoiceCallAvailable();
}
