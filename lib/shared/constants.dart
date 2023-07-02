import 'dart:math';

import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/platform.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

const APPLICATION_NAME = "We";
const APPLICATION_TERMS_OF_USE_URL = "https://wemessenger.ir/terms";
const APPLICATION_LANDING_URL = "https://wemessenger.ir";
const APPLICATION = Applications.we;
// Links Constants
const APPLICATION_FOLDER_NAME = "We";
const APPLICATION_DOMAIN = "wemessenger.ir";
const ABORTED_ADDRESS = "wemessenger.ir";
const LB_ADDRESS = "lb.wemessenger.ir";
const SHARE_PRIVATE_DATA_ACCEPTANCE_URL = "spda";
const ADD_CONTACT_URL = "ac";
const SEND_TEXT_URL = "text";
const JOIN_URL = "join";
const LOGIN_URL = "login";
const USER_URL = "user";
const GROUP_URL = "group";
const CHANNEL_URL = "channel";

// Version Constants
const VERSION = 3;
const REVISION = 0;
const APP_VERSION = "$VERSION.$REVISION";
// const INSTALL_FROM = "سایت";

//messageRepo
const RANDOM_SIZE = 100000;

// Padding and Margin Constants
const p24 = 24.0; // 3nd Most usable padding
const p16 = 16.0; // 2nd Most usable padding
const p12 = 12.0; // 5nd Most usable padding
const p8 = 8.0; // 1nd Most usable padding
const p4 = 4.0; // 2nd Most usable padding
const p2 = 2.0; // 4nd Most usable padding

// Time Constants
const ONLINE_TIME = 60000;
const AVATAR_CACHE_TIME = 60 * 60 * 24 * 1000;
const NULL_AVATAR_CACHE_TIME = 12 * 60 * 60 * 1000;
const USER_INFO_CACHE_TIME = 60 * 60 * 24 * 7 * 1000;
const IS_VERIFIED_CACHE_TIME = 60 * 60 * 24 * 7 * 1000;
const REPEATED_DETECTION_TIME = 60 * 10 * 1000; // 10 min
const REPEATED_DETECTION_COUNT = 5; // 5 message Id
const RESEND_SMS_TIMER = 2 * 60;

// Paging Constants
const META_PAGE_SIZE = 30;
const SHOWCASE_PAGE_SIZE = 10;
const PAGE_SIZE = 30;

//Contacts Constants
const MAX_CONTACT_SIZE_TO_SEND = 50;
const MAX_SEND_CONTACT_START_TIME_EXPIRE = 6 * 60 * 60 * 1000;
const INVITE_MESSAGE =
    "$APPLICATION_NAME invite link: $APPLICATION_LANDING_URL";

//FetchRooms Constants
const MAX_ROOM_METADATA_SIZE = 10000;
const FETCH_ROOM_METADATA_LIMIT = 100;
const FETCH_ROOM_METADATA_IN_BACKGROUND_RECONNECT = 20;

// File Constants
const DEFAULT_FILE_TYPE = "application/octet-stream";
const DEFAULT_FILE_DIMENSION = 200;

// Text Message Limitation Constant
const TEXT_MESSAGE_MAX_LENGTH = 60;
const TEXT_MESSAGE_MAX_LINE = 30;
const INPUT_MESSAGE_TEXT_FIELD_MAX_LINE = TEXT_MESSAGE_MAX_LINE * 10;
const INPUT_MESSAGE_TEXT_FIELD_MAX_LENGTH =
    INPUT_MESSAGE_TEXT_FIELD_MAX_LINE * TEXT_MESSAGE_MAX_LENGTH;

// Feature Flags
const bool TWO_STEP_VERIFICATION_IS_AVAILABLE = false;
const bool WEBVIEW_IS_AVAILABLE = true;
const bool SHOWCASES_SHOWING_FIRST = false;

// Fake User Constants
final FAKE_USER_UID = Uid()
  ..category = Categories.USER
  ..node = "fake_user";
const FAKE_USER_NAME = "John Doe";

// Call Constants
//Stun Servers
const STUN_SERVER_URL_1 = 'stun:217.218.7.16:3478';
const STUN_SERVER_URL_2 = 'stun:157.90.138.141:3478';
const STUN_SERVER_URL_3 = 'stun:stun.l.google.com:19302';

//Turn Server1
const TURN_SERVER_URL_1 = 'turn:157.90.138.141:3478?transport=udp';
const TURN_SERVER_USERNAME_1 = 'deliver2';
const TURN_SERVER_PASSWORD_1 = 'Deliver2@123';

//Turn Server2
const TURN_SERVER_URL_2 = 'turn:217.218.7.16:3478?transport=udp';
const TURN_SERVER_USERNAME_2 = 'deliver';
const TURN_SERVER_PASSWORD_2 = 'Deliver@123';

//Status Webrtc
const STATUS_CAMERA_OPEN = "camera-open";
const STATUS_CAMERA_CLOSE = "camera-close";
const STATUS_MIC_OPEN = "mic-open";
const STATUS_MIC_CLOSE = "mic-close";
const STATUS_CALL_ON_HOLD = "call-on-hold";
const STATUS_SPEAKING_AUDIO_LEVEL = "speaking-audio-level";
const STATUS_CALL_ON_HOLD_ENDED = "call-ended";
const STATUS_SHARE_SCREEN = "share-screen";
const STATUS_SHARE_VIDEO = "share-video";
const STATUS_CONNECTION_CONNECTING = "connection-connecting";
const STATUS_CONNECTION_CONNECTED = "connection-connected";
const STATUS_CONNECTION_FAILED = "connection-failed";
const STATUS_CONNECTION_DISCONNECTED = "connection-disconnected";
const STATUS_CONNECTION_ENDED = "connection-ended";
const STATUS_CAMERA_SWITCH_ON = "camera-switch-on";
const STATUS_CAMERA_SWITCH_OFF = "camera-switch-off";

//Call Configuration
const WEBRTC_MAX_BITRATE_LOW_AUDIO_CALL = 32000; // 32 kbps
const WEBRTC_MAX_BITRATE_NORMAL_AUDIO_CALL = 64000; // 64 kbps
const WEBRTC_MIN_BITRATE_HIGH_QUALITY_AUDIO_CALL = 256000; // 256 kbps
const WEBRTC_MAX_BITRATE_LOW_VIDEO_CALL = 128000; // 128 kbps
const WEBRTC_MAX_BITRATE_NORMAL_VIDEO_CALL = 512000; // 512 kbps
const ICE_CANDIDATE_NUMBER = 15;
const ICE_CANDIDATE_TIME_LIMIT = 1500;
const CALL_DATA_EXPIRE_CHECK_TIME_MS = 100000;

//KEYBOARD SIZE
const KEYBOARD_DEFAULT_SIZE_LANDSCAPE = 254.0;
const KEYBOARD_DEFAULT_SIZE_PORTRAIT = 200.0;

//Colors
const INTRO_COLOR_BACKGROUND = Color(0xffdceefc);
const INTRO_COLOR_FOREGROUND = Color(0xff095da4);
const grayColor = Color.fromRGBO(55, 58, 62, 1.0);
const backgroundColorCard = Color.fromRGBO(44, 99, 45, 1.0);

const DEFAULT_ZOOM_LEVEL = 15.0;
const androidSmallCallWidgetVerticalMargin = 120.0;

// Shared Dao Settings Constants
enum SharedKeys {
  SHARED_DAO_ACCESS_TOKEN_KEY,
  SHARED_DAO_REFRESH_TOKEN_KEY,
  SHARED_DAO_REFRESH_TOKEN_KEY_PREV,
  SHARED_DAO_LOCAL_PASSWORD,
  SHARED_DAO_THEME_IS_DARK,
  SHARED_DAO_THEME_COLOR,
  SHARED_DAO_THEME_SHOW_COLORFUL_MESSAGES,
  SHARED_DAO_THEME_SHOW_TEXTS_JUSTIFIED,
  SHARED_DAO_THEME_SHOW_LINK_PREVIEW,
  SHARED_DAO_THEME_PLAY_IN_CHAT_SOUNDS,
  SHARED_DAO_THEME_PATTERN,
  SHARED_DAO_THEME_FONT_SIZE,
  SHARED_DAO_SEND_BY_ENTER,
  SHARED_DAO_FIREBASE_SETTING_IS_SET,
  SHARED_DAO_ALL_ROOMS_FETCHED,
  SHARED_DAO_NOTIFICATION_FOREGROUND,
  SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED,
  SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED,
  SHARED_DAO_DB_VERSION,
  SHARED_DAO_INIT_APP_PAGE,
  SHARED_DAO_IS_SHOWCASE_ENABLE,
  SHARED_DAO_SCROLL_POSITION,
  SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE,
  SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED,
  SHARE_DAO_HOST_SET_BY_USER,
  SHARE_DAO_WEB_VIEW_URL,
  SHARE_DAO_SERVICES_INFO,
  SHARED_DAO_FIREBASE_TOKEN,
  SHARED_DAO_SHOW_EVENTS,
  POWER_SAVE_BATTERY_LEVEL,
  PERFORMANCE_MODE,
  LAST_MESSAGE_DELIVERY_ACK,
  WINDOW_FRAME,
  USE_BAD_CERTIFICATE_CONNECTION,
  LANGUAGE,
  VIDEO_CALL_QUALITY,
  VIDEO_FRAME_RATE_LIMITATION,
  LOG_LEVEL,
  LOG_IN_FILE_ENABLE,
  SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT,
  SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT_IN_MEMORY,
  SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE,
  SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE_IN_MEMORY,
  SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS,
  SHARED_DAO_KEY_LAST_ROOM_METADATA_UPDATE_TIME,
  ONCE_SHOW_NEW_VERSION_INFORMATION,
  ONCE_SHOW_CONTACT_DIALOG,
  ONCE_SHOW_MICROPHONE_DIALOG,
  ONCE_SHOW_CAMERA_DIALOG,
  ONCE_SHOW_MEDIA_LIBRARY_DIALOG,
  SHOW_DEVELOPER_PAGE,
  ICE_CANDIDATE_NUMBERS,
  ICE_CANDIDATE_TIME_LIMIT,
  REPEAT_ANIMATED_EMOJI,
  REPEAT_ANIMATED_STICKERS,
  SHOW_ANIMATED_EMOJI,
  SHOW_ROOM_BACKGROUND,
  SHOW_BLURRED_COMPONENTS,
  SHOW_MESSAGE_DETAILS,
  SHOW_ANIMATIONS,
  SHOW_ANIMATED_AVATARS,
  SHOW_AVATAR_IMAGES,
  SHOW_AVATARS,
  PARSE_AND_SHOW_EMOJIS,
  LOW_NETWORK_USAGE_VOICE_CALL,
  LOW_NETWORK_USAGE_VIDEO_CALL,
  HIGH_QUALITY_CALL,
  NAVIGATION_PANEL_SIZE,
  SHOW_WS_WITH_HIGH_FRAME_RATE,
  HAS_PROFILE,
  VERSION,
  ACCOUNT,
}

// Notification Constants
const String OPEN_CHAT_ACTION_ID =
    'open_chat'; // A notification action which triggers a App navigation event
const String DARWIN_NOTIFICATION_CATEGORY_TEXT =
    'textCategory'; // Defines a iOS/MacOS notification category for text input actions.
const String CLOSE_ACTION_ID = 'close'; // action id for close
const String REPLY_ACTION_ID = 'reply'; // action id for reply
const String MARK_AS_READ_ACTION_ID =
    'mark_as_read'; // action id for mark as read

// Hive Tables ID Constants
const AVATAR_TRACK_ID = 1;
const LAST_ACTIVITY_TRACK_ID = 2;
const CONTACT_TRACK_ID = 3;
const UID_ID_NAME_TRACK_ID = 4;
const SEEN_TRACK_ID = 5;
const FILE_INFO_TRACK_ID = 6;
const MUC_TRACK_ID = 7;
const MEMBER_TRACK_ID = 8;
const ROLE_TRACK_ID = 9;
const BOT_INFO_TRACK_ID = 10;
const MESSAGE_TRACK_ID = 11;
const MESSAGE_TYPE_TRACK_ID = 12;
const ROOM_METADATA_TRACK_ID = 14;
const SENDING_STATUS_TRACK_ID = 15;
const META_TRACK_ID = 16;
const META_COUNT_TRACK_ID = 17;
const META_TYPE_TRACK_ID = 18;
const LIVE_LOCATION_TRACK_ID = 19;
const CALL_INFO_TRACK_ID = 20;
const CALL_EVENT_TRACK_ID = 21;
const CALL_STATUS_TRACK_ID = 22;
const CALL_TYPE_TRACK_ID = 23;
const ACCOUNT_TRACK_ID = 24;
const AUTO_DOWNLOAD_TRACK_ID = 25;
const AUTO_DOWNLOAD_ROOM_CATEGORY_TRACK_ID = 26;
const CURRENT_CALL_INFO_TRACK_ID = 27;
const MESSAGE_BRIEF_TRACK_ID = 28;
const MUC_Type_TRACK_ID = 29;
const SHOW_CASE_TRACK_ID = 30;
const ACTIVE_NOTIFICATION_TRACK_ID = 31;
const BOX_INFO_TRACK_ID = 32;
const RECENT_EMOJI_TRACK_ID = 33;
const EMOJI_SKIN_TONE_TRACK_ID = 34;
const RECENT_ROOMS_TRACK_ID = 35;
const RECENT_SEARCH_TRACK_ID = 36;
const CALL_DATE_USAGE_TRACK_ID = 37;
const PENDING_MESSAGE_TRACK_ID = 38;
const BROADCAST_SUCCESS_AND_FAILED_COUNT_TRACK_ID = 39;
const BROADCAST_STATUS_TRACK_ID = 40;
const BROADCAST_MESSAGE_STATUS_TYPE_TRACK_ID = 41;
const IS_VERIFIED_TRACK_ID = 42;
const LAST_CALL_STATUS_TRACK_ID = 43;
const ANNOUNCMENT_TRACK_ID = 44;

// Emoji
const MAX_RECENT_EMOJI_LENGTH = 48;
const double PERSISTENT_EMOJI_HEADER_HEIGHT = 42.0;
const double DESKTOP_EMOJI_OVERLAY_WIDTH = 360.0;

//RECENT ROOMS & RECENT SEARCH
const MAX_RECENT_ROOM_LENGTH = 20;
const MAX_RECENT_SEARCH_LENGTH = 40;

//BROAD CAST DELAY BETWEEN SENDING  MESSAGE IN SECOND
const BROADCAST_MESSAGE_DELAY = 2;
const BROADCAST_SMS_DELAY = 1;
const BROADCAST_CHANNEL_MAX_MEMBER_COUNT = 100;
const MUC_MAX_MEMBER_COUNT = 200000;

//FEATURE DISCOVERY ID
const QRCODE_FEATURE = 'QRCODE_FEATURE';
const SETTING_FEATURE = 'SETTING_FEATURE';
const SHOW_CASE_FEATURE = 'SHOW_CASE_FEATURE';
const CALL_FEATURE = 'CALL_FEATURE';

//FOCUS NODE
final MAIN_SEARCH_BOX_FOCUS_NODE = FocusNode(canRequestFocus: false);

// UI
const double APPBAR_HEIGHT = 50.0;
const double BAR_HEIGHT = 50.0;
const double FLUID_MAX_WIDTH = 500.0;
const double FLUID_MAX_HEIGHT = 640.0;
const double FLUID_CONTAINER_MAX_WIDTH = 768.0;
const double LARGE_BREAKDOWN_SIZE_WIDTH = 768.0;
const double LARGE_BREAKDOWN_SIZE_HEIGHT = 550.0;
const double VERY_LARGE_BREAKDOWN_SIZE = 1150.0;
const double NAVIGATION_PANEL_MIN_WIDTH = 320.0;
const double MIN_WIDTH = 200.0;
const int SCROLL_DOWN_BUTTON_HIDING_TIME = 2000;
const double SELECTED_MESSAGE_CHECKBOX_WIDTH = 35;
const MAIN_BORDER_RADIUS_SIZE = 28.0;
const CHAT_AVATAR_RADIUS = 26.0;
const mainBorder = BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS_SIZE));
const secondaryBorder = BorderRadius.all(Radius.circular(12));
const tertiaryBorder = BorderRadius.all(Radius.circular(8));
const messageBorder = BorderRadius.all(Radius.circular(14));
const buttonBorder = BorderRadius.all(Radius.circular(20));

////////////////////// Functions //////////////////////

// Screen Breakdown
bool isLargeWidthForIntro(double width) => width > FLUID_MAX_WIDTH * 1.7;

bool isLargeWidth(double width) => width > LARGE_BREAKDOWN_SIZE_WIDTH;

bool isLargeHeight(double height) => height > LARGE_BREAKDOWN_SIZE_HEIGHT;

bool isLarge(BuildContext context) {
  if (isDesktopDevice ||
      MediaQuery.of(context).orientation == Orientation.portrait) {
    return isLargeWidth(
      MediaQuery.of(context).size.width,
    );
  } else {
    return isLargeHeight(
      MediaQuery.of(context).size.height,
    );
  }
}

bool isVeryLargeWidth(double width) => width > VERY_LARGE_BREAKDOWN_SIZE;

bool isVeryLarge(BuildContext context) => isVeryLargeWidth(
      MediaQuery.of(context).size.width,
    );

// Dynamics
double maxWidthOfMessage(double width) =>
    min(width * 0.9 - SELECTED_MESSAGE_CHECKBOX_WIDTH, 450);

double minWidthOfMessage(double width) =>
    min(maxWidthOfMessage(width), 200 - SELECTED_MESSAGE_CHECKBOX_WIDTH);

double showcaseBoxWidth() =>
    max(min(280.0, NAVIGATION_PANEL_MIN_WIDTH * 0.9), 220.0);

double showcaseBoxSingleBannerWidth() =>
    min(304.0, NAVIGATION_PANEL_MIN_WIDTH * 0.98);

enum CallSlot { DATA_SLOT_1, DATA_SLOT_2, DATA_SLOT_3 }
