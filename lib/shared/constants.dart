import 'dart:math';

import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

const APPLICATION_NAME = "We";
const APPLICATION_TERMS_OF_USE_URL = "https://wemessenger.ir/terms";
const APPLICATION_LANDING_URL = "https://wemessenger.ir";
const APP_NAME = "";
// Links Constants
const APPLICATION_FOLDER_NAME = "We";
const APPLICATION_DOMAIN = "wemessenger.ir";
const SHARE_PRIVATE_DATA_ACCEPTANCE_URL = "spda";
const ADD_CONTACT_URL = "ac";
const SEND_TEXT_URL = "text";
const JOIN_URL = "join";
const LOGIN_URL = "login";
const USER_URL = "user";
const GROUP_URL = "group";
const CHANNEL_URL = "channel";

// Version Constants
const VERSION = "1.9.9";
const SHOW_NEW_VERSION_INFORMATION_KEY = "SHOW_NEW_VERSION_INFORMATION_KEY";
const SHOW_NEW_VERSION_INFORMATION_COUNT = 50;
const SHOW_NEW_VERSION_INFORMATION_PERIOD = 2 * 60 * 60 * 1000;

//messageRepo
const RANDOM_SIZE = 100000;

// Time Constants
const ONLINE_TIME = 60000;
const AVATAR_CACHE_TIME = 60 * 60 * 24 * 1000;
const NULL_AVATAR_CACHE_TIME = 60 * 60 * 1 * 1000;
const USER_INFO_CACHE_TIME = 60 * 60 * 24 * 7 * 1000;

// Paging Constants
const MEDIA_PAGE_SIZE = 30;
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
const MAX_FILE_SIZE_BYTE = 104857600.0; //100MB
const MIN_FILE_SIZE_BYTE = 0.0; //0MB
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
const bool SHOWCASES_IS_AVAILABLE = false;
const bool SHOWCASES_SHOWING_FIRST = false;

// Fake User Constants
final FAKE_USER_UID = Uid()
  ..category = Categories.USER
  ..node = "fake_user";
const FAKE_USER_NAME = "John Doe";

// Call Constants
const STUN_SERVER_URL = 'stun:217.218.7.16:3478';
const STUN_SERVER_URL_2 = 'stun:stun.l.google.com:19302';
const TURN_SERVER_URL =
    'turn:217.218.7.16:3478?transport=udp'; //turn:47.102.201.4:19303?transport=udp //turn:217.218.7.16:3478?transport=udp
const TURN_SERVER_USERNAME = 'deliver'; //1639512193:flutter-webrtc //deliver
const TURN_SERVER_PASSWORD =
    'Deliver@123'; //WyxSLuhpUNpFWrD44gmTGN0q93E //Deliver@123
const TURN_SERVER_URL_2 =
    'turn:47.102.201.4:19303?transport=udp'; //turn:47.102.201.4:19303?transport=udp //turn:217.218.7.16:3478?transport=udp
const TURN_SERVER_USERNAME_2 =
    '1639512193:flutter-webrtc'; //1639512193:flutter-webrtc //deliver
const TURN_SERVER_PASSWORD_2 =
    'WyxSLuhpUNpFWrD44gmTGN0q93E'; //WyxSLuhpUNpFWrD44gmTGN0q93E //Deliver@123
const STATUS_CAMERA_OPEN = "camera-open";
const STATUS_CAMERA_CLOSE = "camera-close";
const STATUS_MIC_OPEN = "mic-open";
const STATUS_MIC_CLOSE = "mic-close";
const STATUS_CALL_ON_HOLD = "call-on-hold";
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
const WEBRTC_MAX_BITRATE =
    256000; // 256 kbps with 2 Mbps we can have about 10 concurrent at high rate
const WEBRTC_MIN_BITRATE =
    128000; // 256 kbps with 2 Mbps we can have about 20 concurrent at high rate
const WEBRTC_MAX_FRAME_RATE =
    30; // 256 kbps with 2 Mbps we can have about 20 concurrent at high rate

// Shared Dao Settings Constants
const SHARED_DAO_SHOW_CONTACT_DIALOG = "SHARED_DAO_SHOW_CONTACT_DIALOG";
const SHARED_DAO_THEME_IS_DARK = "SHARED_DAO_THEME_IS_DARK";
const SHARED_DAO_THEME_COLOR = "SHARED_DAO_THEME_COLOR";
const SHARED_DAO_THEME_SHOW_COLORFUL = "SHARED_DAO_THEME_SHOW_COLORFUL";
const SHARED_DAO_THEME_PATTERN = "SHARED_DAO_THEME_PATTERN";
const SHARED_DAO_SEND_BY_ENTER = "SHARED_DAO_SEND_BY_ENTER";
const SHARED_DAO_LANGUAGE = "SHARED_DAO_LANGUAGE";
const SHARED_DAO_FIREBASE_SETTING_IS_SET = "SHARED_DAO_FIREBASE_SETTING_IS_SET";
const SHARED_DAO_CURRENT_USER_UID = "SHARED_DAO_CURRENT_USER_UID";
const SHARED_DAO_ACCESS_TOKEN_KEY = "SHARED_DAO_ACCESS_TOKEN_KEY";
const SHARED_DAO_REFRESH_TOKEN_KEY = "SHARED_DAO_REFRESH_TOKEN_KEY";
const SHARED_DAO_LOCAL_PASSWORD = "SHARED_DAO_LOCAL_PASSWORD";
const SHARED_DAO_ALL_ROOMS_FETCHED = "SHARED_DAO_ALL_ROOMS_FETCHED";
const SHARED_DAO_LOG_LEVEL = "SHARED_DAO_LOG_LEVEL";
const SHARED_DAO_LOG_IN_FILE_ENABLE = "SHARED_DAO_LOG_IN_FILE_ENABLE";
const SHARED_DAO_NOTIFICATION_FOREGROUND = "SHARED_DAO_NOTIFICATION_FOREGROUND";
const SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED =
    "SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED";
const SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED =
    "SHARED_DAO_NOTIFICATION_ADVANCE_MODE_DISABLED";
const SHARED_DAO_VERSION = "SHARED_DAO_VERSION";
const SHARED_DAO_DB_VERSION = "SHARED_DAO_DB_VERSION";
const SHARED_DAO_IS_SHOWCASE_ENABLE = "SHARED_DAO_IS_SHOWCASE_ENABLE";

const SHARED_DAO_SCROLL_POSITION = "SHARED_DAO_SCROLL_POSITION";
const SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE =
    "SHARED_DAO_IS_AUTO_NIGHT_MODE_ENABLE";
const SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED =
    "SHARED_DAO_TWO_STEP_VERIFICATION_ENABLED";
const SHARED_DAO_WINDOWS_SIZE = "SHARED_DAO_WINDOWS_SIZE";
const SHARED_DAO_BAD_CERTIFICATE_CONNECTION =
    "SHARED_DAO_USE_CERTIFICATE_CONNECTION";
const SHARE_DAO_HOST_SET_BY_USER = "SHARE_DAO_HOST_SET_BY_USER";
const SHARED_DAO_FIREBASE_TOKEN = "SHARED_DAO_FIREBASE_TOKEN";

//KEYBOARD SIZE
const SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT = "SHARED_DAO_KEY_BOARD_SIZE_PORTRAIT";

const SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE =
    "SHARED_DAO_KEY_BOARD_SIZE_LANDSCAPE";

// FEATURE FLAGS
const SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS =
    "SHARED_DAO_FEATURE_FLAGS_SHOW_DEVELOPER_DETAILS";

const BETA_USERS_UID_LIST = [
  "0:0fe14dcc-52e9-41c2-be8b-b995c28d8310", // "Esmael Dansi"
  "0:3e85b94e-1a0b-4b11-b7e2-3b5e96bcabfd", // "dansi"
  "0:db8ab0da-d0cb-4aaf-b642-2419ef59f05d", // "Esmael Dansi2"
  "0:1cde64f0-d68b-4767-9123-5a90b4b06c1c", // "Beheshti"
  "0:e9cdce3d-5528-4ea2-9698-c379617d0329", // "Chitsaz"
  "0:b89fa74c-a583-4d64-aa7d-56ab8e37edcd", // "Chitsaz 2"
  "0:1a40fc30-27a5-4497-ba08-3c9fab086ef7", // "Shariatikia"
  "0:bfe1a3aa-ed7f-46c4-a4c0-ea7267eebdea", // "Shariatikia 2"
  "0:e2014d58-1979-4cb0-9d37-0101beb4f61d", // "Arash"
  "0:a707279e-cdaf-4a98-a418-1df9517bc189", // "Habibollah Rad"
  "0:2c821e6e-7c33-4b1e-9467-4b0e25556d71", // "Hossein Zaree"
  "0:63dac049-5bb7-4a8e-ab5f-a9f415e7620d", // "Ali Nasiri"
  "0:120ce7cd-0a02-4999-b54a-e0d13dc8247b", // "Meysam Mirzaee"

  "0:13a47dd4-1867-431d-b340-16fc9ad2f444", // "Ahmad Mohammad Zadeh"
  "0:d62989a3-2ef3-4ec8-a025-9906059492a8", // "Amirhossein Mazraee"
  "0:63dac049-5bb7-4a8e-ab5f-a9f415e7620d", // "Ali Nasiri"
  "0:8160fae8-3da2-42dd-943b-7a1aa98ae30e", // "Hadi Pakatchi"
  "0:d93554de-4538-4071-ae74-845fdf193c3b", // "Hadi Zamani"
  "0:51af5102-317d-4e40-a7f2-c64d973f4a50", // "Hamed Aghababayi"
  "0:d15788f8-3954-418f-8bd4-41af4eed4ac8", // "Hamed Hasani"
  "0:e4e9fe2a-3c18-48bf-b3b6-d5acd9f93d63", // "HamedReza Ghasemi"
  "0:81e3b5b8-25eb-45fd-802f-bfa84a137b43", // "Mahdi Karami"
  "0:089a8c7a-b551-4d71-87d7-4247ea96b7a0", // "Mohammad Ghadiri"
  "0:5b53c2be-2d51-418d-a774-447f821aa3e5", // "Jafar Aghayari"
  "0:ee53216c-28ed-4e04-b71a-c2644aee3f1b", // "Mohammad Reza Rafeie"
  "0:86cc19a0-72d7-4019-8d14-6ec2b77e508b", // "Morteza Abrari"
  "0:38529d38-590b-4428-ad99-61d2c11d47fc", // "Morteza Abrari"
  "0:8bbb27a4-9ba0-4008-9769-b681e598f054", // "Vahid Ghasemi"
  "0:267b35f2-d457-4725-b8e9-ecb5b8a6d9fd", // "Alireza Salimi"
  "0:09ffbc77-78ff-4656-bfd0-0fce97d76e31", // "Alireza Ahadi"
  "0:1d0e274f-e310-4028-a101-3fd4fedf0292", // "Khanom Esbati"
  "0:cd1f4e71-d9ee-4e9e-ba00-05939f8beb81", // "Arian Reyhane"
  "0:e2063c67-696b-49ea-8d9d-be13a01e4cc3", // "Hamid Afzal"
  "0:e5b4dfa2-2f71-4d22-a0e1-0303b6c3c9a4", // "Banif"
  "0:0c2a619f-5979-49de-ab6c-1f904d4ecbc2", // "Alireza Kazemi"
  "0:34735204-6f3b-407e-adce-3a9fb14bb879", // "Masoud Ramfar"
  "0:670cb757-ba25-4069-b180-6729d1b0bd53", // "Moghimi"
  "0:d27c0149-46e6-48ee-ac7d-9b9a9484aae3", // "Arshia Badi"
  "0:6362efca-ceed-443a-be71-2989d3968fa8", // "Ali Hosseini"
  "0:387d60f3-7222-4f4f-b8c3-4fd5d14b5a8e", // "Talebi"
  "0:4321e7b3-c5c3-4ee4-9682-11096199cda5", // "Hadi Aghayi"
  "0:eb3b7553-ec68-479b-ba38-06b1ced65bec", // "Ramazani"
];

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
const PENDING_MESSAGE_TRACK_ID = 13;
const ROOM_METADATA_TRACK_ID = 14;
const SENDING_STATUS_TRACK_ID = 15;
const MEDIA_TRACK_ID = 16;
const MEDIA_META_DATA_TRACK_ID = 17;
const MEDIA_TYPE_TRACK_ID = 18;
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

// Emoji
const MAX_RECENT_EMOJI_LENGTH = 48;
const double PERSISTENT_EMOJI_HEADER_HEIGHT = 42.0;
const double DESKTOP_EMOJI_OVERLAY_WIDTH = 360.0;

//FEATURE DISCOVERY ID
const FEATURE_1 = 'feature1';
const FEATURE_2 = 'feature2';
const FEATURE_3 = 'feature3';
const FEATURE_4 = 'feature4';
const FEATURE_5 = 'feature5';
const FEATURE_6 = 'feature6';

// Animation
const FAST_ANIMATION_DURATION = Duration(milliseconds: 50);
const ANIMATION_DURATION = Duration(milliseconds: 100);
const SLOW_ANIMATION_DURATION = Duration(milliseconds: 200);
const MOTION_STANDARD_ANIMATION_DURATION = Duration(milliseconds: 300);
const VERY_SLOW_ANIMATION_DURATION = Duration(milliseconds: 350);
const SUPER_SLOW_ANIMATION_DURATION = Duration(milliseconds: 500);

//FOCUS NODE
final MAIN_SEARCH_BOX_FOCUS_NODE = FocusNode(canRequestFocus: false);

// UI
const double APPBAR_HEIGHT = 56.0;
const double FLUID_MAX_WIDTH = 500.0;
const double FLUID_MAX_HEIGHT = 640.0;
const double FLUID_CONTAINER_MAX_WIDTH = 768.0;
const double LARGE_BREAKDOWN_SIZE_WIDTH = 768.0;
const double LARGE_BREAKDOWN_SIZE_HEIGHT = 550.0;
const double VERY_LARGE_BREAKDOWN_SIZE = 1150.0;
const double NAVIGATION_PANEL_SIZE = 320.0;
const double MIN_WIDTH = 200.0;
const int SCROLL_DOWN_BUTTON_HIDING_TIME = 2000;
const double SELECTED_MESSAGE_CHECKBOX_WIDTH = 35;
const MAIN_BORDER_RADIUS_SIZE = 28.0;
const mainBorder = BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS_SIZE));
const secondaryBorder = BorderRadius.all(Radius.circular(12));
const tertiaryBorder = BorderRadius.all(Radius.circular(8));
const messageBorder = BorderRadius.all(Radius.circular(14));
const buttonBorder = BorderRadius.all(Radius.circular(20));

////////////////////// Functions //////////////////////

// Screen Breakdown
bool isLargeWidth(double width) => width > LARGE_BREAKDOWN_SIZE_WIDTH;

bool isLargeHeight(double height) => height > LARGE_BREAKDOWN_SIZE_HEIGHT;

bool isLarge(BuildContext context) {
  if (isDesktop || MediaQuery.of(context).orientation == Orientation.portrait) {
    return isLargeWidth(MediaQuery.of(context).size.width);
  } else {
    return isLargeHeight(MediaQuery.of(context).size.height);
  }
}

bool isVeryLargeWidth(double width) => width > VERY_LARGE_BREAKDOWN_SIZE;

bool isVeryLarge(BuildContext context) =>
    isVeryLargeWidth(MediaQuery.of(context).size.width);

// Dynamics
double animationSquareSize(BuildContext context) => isLarge(context)
    ? min(FLUID_MAX_WIDTH * 0.7, FLUID_MAX_HEIGHT * 0.4)
    : min(
        MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height * 0.7,
      );

double maxWidthOfMessage(BuildContext context) => min(
      (MediaQuery.of(context).size.width -
                  (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) *
              0.8 -
          SELECTED_MESSAGE_CHECKBOX_WIDTH,
      450,
    );

double minWidthOfMessage(BuildContext context) =>
    min(maxWidthOfMessage(context), 200 - SELECTED_MESSAGE_CHECKBOX_WIDTH);
