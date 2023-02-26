import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:rxdart/rxdart.dart';

class UxService {
  static bool showDeveloperPage = false;

  final _sharedDao = GetIt.I.get<SharedDao>();

  final _themeIndex = BehaviorSubject.seeded(0);
  final _patternIndex = BehaviorSubject.seeded(0);
  final _sliderValue = BehaviorSubject<double>.seeded(0);
  final _themeIsDark = BehaviorSubject.seeded(false);
  final _showColorful = BehaviorSubject.seeded(false);

  final _isAllNotificationDisabled = BehaviorSubject.seeded(false);
  final _isNotificationAdvanceModeDisabled = BehaviorSubject.seeded(true);
  final _isAutoNightModeEnable = BehaviorSubject.seeded(true);
  final _sendByEnter = BehaviorSubject.seeded(isDesktop);
  final _keyBoardSizePortrait = BehaviorSubject<double?>.seeded(null);
  final _keyBoardSizeLandscape = BehaviorSubject<double?>.seeded(null);
  double maxKeyboardSizePortrait = 0;
  double maxKeyboardSizeLandscape = 0;

  late StreamSubscription<bool> _isAllNotificationDisabledSubscribe;

  void init() {
    _isAllNotificationDisabledSubscribe = _sharedDao
        .getBooleanStream(SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED)
        .distinct()
        .listen((isDisabled) => _isAllNotificationDisabled.add(isDisabled));
  }

  void reInitialize() {
    _isAllNotificationDisabledSubscribe.cancel();
    init();
  }

  UxService() {
    _sharedDao
        .getBooleanStream(
      SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE,
      defaultValue: true,
    )
        .listen((isEnable) {
      _isAutoNightModeEnable.add(isEnable);
      checkPlatformBrightness();
    });
    _sharedDao
        .getStream(
      SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT,
    )
        .listen((value) {
      if (value != null && value != "null") {
        _keyBoardSizePortrait.add(double.parse(value));
      }
    });
    _sharedDao
        .getStream(
      SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE,
    )
        .listen((value) {
      if (value != null && value != "null") {
        _keyBoardSizeLandscape.add(double.parse(value));
      }
    });
    window.onPlatformBrightnessChanged = () {
      checkPlatformBrightness();
    };
    _sharedDao
        .getBooleanStream(SHARED_DAO_THEME_SHOW_COLORFUL)
        .distinct()
        .listen((isEnable) => _showColorful.add(isEnable));

    init();

    _sharedDao
        .getBooleanStream(SHARED_DAO_SEND_BY_ENTER, defaultValue: isDesktop)
        .distinct()
        .listen((sbn) => _sendByEnter.add(sbn));

    _sharedDao
        .getBoolean(
          SHARED_DAO_THEME_IS_DARK,
          defaultValue: isAutoNightModeEnable &&
              window.platformBrightness == Brightness.dark,
        )
        .then(_themeIsDark.add);

    _sharedDao.get(SHARED_DAO_THEME_COLOR).then((event) {
      if (event != null) {
        try {
          final colorIndex = int.parse(event);
          _themeIndex.add(colorIndex);
        } catch (_) {}
      }
    });

    _sharedDao.get("textSize").then((event) {
      if (event != null) {
        try {
          final textSize = double.parse(event);
          _sliderValue.add(textSize);
        } catch (_) {}
      }
    });

    _sharedDao.get(SHARED_DAO_THEME_PATTERN).then((event) {
      if (event != null) {
        try {
          final patternIndex = int.parse(event);
          _patternIndex.add(patternIndex);
        } catch (_) {}
      }
    });

    _sharedDao
        .getBooleanStream(
      SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED,
      defaultValue: true,
    )
        .listen((event) {
      _isNotificationAdvanceModeDisabled.add(event);
    });
  }

  void checkPlatformBrightness() {
    if (isAutoNightModeEnable) {
      window.platformBrightness == Brightness.dark
          ? toggleThemeToDarkMode()
          : toggleThemeToLightMode();
    }
  }

  Stream<int> get themeIndexStream => _themeIndex.distinct();

  Stream<int> get patternIndexStream => _patternIndex.distinct();

  Stream<double> get sliderValueStream => _sliderValue.distinct();

  Stream<bool> get themeIsDarkStream => _themeIsDark.distinct();

  Stream<bool> get showColorfulStream => _showColorful.distinct();

  ThemeData get theme =>
      getThemeScheme(_themeIndex.value).theme(isDark: _themeIsDark.value);

  CorePalette getCorePalette() =>
      CorePalette.of(palettes[themeIndex % palettes.length].value);

  ExtraThemeData get extraTheme =>
      getThemeScheme(_themeIndex.value).extraTheme(isDark: _themeIsDark.value);

  bool get themeIsDark => _themeIsDark.value;

  bool get showColorful => _showColorful.value;

  int get themeIndex => _themeIndex.value;

  int get patternIndex => _patternIndex.value;

  double get sliderValue => _sliderValue.value ;

  bool get sendByEnter => isDesktop && _sendByEnter.value;

  bool get isAllNotificationDisabled => _isAllNotificationDisabled.value;

  bool get isNotificationAdvanceModeDisabled =>
      _isNotificationAdvanceModeDisabled.value;

  bool get isAutoNightModeEnable => _isAutoNightModeEnable.value;

  double? getKeyBoardSizePortrait() => _keyBoardSizePortrait.value;

  double? getKeyBoardSizeLandscape() => _keyBoardSizeLandscape.value;

  BehaviorSubject<bool> get isAutoNightModeEnableStream =>
      _isAutoNightModeEnable;

  void toggleThemeLightingMode() {
    _disableAutoNightMode();
    if (_themeIsDark.value) {
      toggleThemeToLightMode();
    } else {
      toggleThemeToDarkMode();
    }
  }

  void toggleThemeToLightMode({bool forceToDisableAutoNightMode = false}) {
    if (forceToDisableAutoNightMode) {
      _disableAutoNightMode();
    }
    _sharedDao.putBoolean(SHARED_DAO_THEME_IS_DARK, false);
    _themeIsDark.add(false);
  }

  void setKeyBoardSizePortrait(double size) {
    final savedSize = getKeyBoardSizePortrait();
    maxKeyboardSizePortrait = max(maxKeyboardSizePortrait, size);

    if (savedSize != maxKeyboardSizePortrait) {
      _sharedDao.put(
        SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT,
        maxKeyboardSizePortrait.toString(),
      );
      _keyBoardSizePortrait.add(maxKeyboardSizePortrait);
    }
  }

  void setKeyBoardSizeLandScape(double size) {
    final savedSize = getKeyBoardSizeLandscape();
    maxKeyboardSizeLandscape = max(maxKeyboardSizeLandscape, size);

    if (savedSize != maxKeyboardSizeLandscape) {
      _sharedDao.put(
        SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE,
        maxKeyboardSizeLandscape.toString(),
      );
      _keyBoardSizeLandscape.add(maxKeyboardSizeLandscape);
    }
  }

  void _disableAutoNightMode() {
    _sharedDao.putBoolean(SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE, false);
    _isAutoNightModeEnable.add(false);
  }

  void toggleThemeToDarkMode({bool forceToDisableAutoNightMode = false}) {
    if (forceToDisableAutoNightMode) {
      _disableAutoNightMode();
    }
    _sharedDao.putBoolean(SHARED_DAO_THEME_IS_DARK, true);
    _themeIsDark.add(true);
  }

  void toggleShowColorful() {
    if (_showColorful.value) {
      _sharedDao.putBoolean(SHARED_DAO_THEME_SHOW_COLORFUL, false);
      _showColorful.add(false);
    } else {
      _sharedDao.putBoolean(SHARED_DAO_THEME_SHOW_COLORFUL, true);
      _showColorful.add(true);
    }
  }

  void selectTheme(int index) {
    _sharedDao.put(SHARED_DAO_THEME_COLOR, index.toString());
    _themeIndex.add(index);
  }

  void selectPattern(int index) {
    _sharedDao.put(SHARED_DAO_THEME_PATTERN, index.toString());
    _patternIndex.add(index);
  }

  void selectTextSize(double index) {
    _sharedDao.put("textSize", index.toString());
    _sliderValue.add(index);
  }

  void toggleSendByEnter() {
    if (sendByEnter == false) {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, true);
    } else {
      _sharedDao.putBoolean(SHARED_DAO_SEND_BY_ENTER, false);
    }
  }

  void toggleIsAllNotificationDisabled() {
    _sharedDao.putBoolean(
      SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED,
      !isAllNotificationDisabled,
    );
  }

  void toggleIsAdvanceNotificationModeDisabled() {
    _sharedDao.putBoolean(
      SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED,
      !isNotificationAdvanceModeDisabled,
    );
  }

  void enableAutoNightMode() {
    _sharedDao.putBoolean(
      SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE,
      true,
    );
  }

  void changeLogLevel(String level) {
    _sharedDao.put(SHARED_DAO_LOG_LEVEL, level);
  }

  void toggleLogInFileEnable() {
    _sharedDao.toggleBoolean(SHARED_DAO_LOG_IN_FILE_ENABLE);
  }
}

class FeatureFlags {
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  // Flags
  final _showDeveloperDetails = BehaviorSubject.seeded(false);

  FeatureFlags() {
    _sharedDao
        .getBooleanStream(SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS)
        .distinct()
        .listen((isEnable) => _showDeveloperDetails.add(isEnable));
  }

  bool labIsAvailable() => _voiceCallFeatureIsPossible();

  bool _voiceCallFeatureIsPossible() => !isLinux;

  // ignore: unused_element
  bool _isBetaUser() =>
      BETA_USERS_UID_LIST.contains(_authRepo.currentUserUid.asString());

  bool get showDeveloperDetails => _showDeveloperDetails.value;

  Future<void> toggleShowDeveloperDetails() async {
    _showDeveloperDetails.add(
      await _sharedDao
          .toggleBoolean(SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS),
    );
  }

  bool hasVoiceCallPermission(String roomUid) {
    return roomUid.asUid().isUser() &&
        !_authRepo.isCurrentUser(roomUid) &&
        isVoiceCallAvailable();
  }

  bool isVoiceCallAvailable() {
    return _voiceCallFeatureIsPossible();
  }

  // void setSliderValue(double sliderValue) {
  //   _sharedDao.put(
  //     "sliderValue",
  //     sliderValue.toString(),
  //   );
  // }

  void setICECandidateNumber(double ICECandidateNumbers) {
    _sharedDao.put(
      "ICECandidateNumbers",
      ICECandidateNumbers.round().toString(),
    );
  }

  void setICECandidateTimeLimit(double ICECandidateTimeLimit) {
    _sharedDao.put(
      "ICECandidateTimeLimit",
      ICECandidateTimeLimit.round().toString(),
    );
  }

  void setICEServerEnable(
    String server, {
    bool newStatus = false,
  }) {
    _sharedDao.putBoolean(server, newStatus);
  }
}
