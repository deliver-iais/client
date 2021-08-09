import 'dart:math';

import 'package:flutter/material.dart';

const APPLICATION_NAME = "Deliver";
const APPLICATION_DOMAIN = "deliver-co.ir";
const VERSION =
    "1.4.0"; // if change the VERSION , is necessary to change version in pubspec.yaml file

const SHARED_DAO_SHOW_CONTACT_DIALOG = "SHARED_DAO_SHOW_CONTACT_DIALOG";
const SHARED_DAO_THEME = "SHARED_DAO_THEME";
const SHARED_DAO_SEND_BY_ENTER = "SHARED_DAO_SEND_BY_ENTER";
const SHARED_DAO_LANGUAGE = "SHARED_DAO_LANGUAGE";
const SHARED_DAO_FIREBASE_SETTING_IS_SET = "SHARED_DAO_FIREBASE_SETTING_IS_SET";
const SHARED_DAO_CURRENT_USER_UID = "SHARED_DAO_CURRENT_USER_UID";
const SHARED_DAO_COUNTRY_CODE = "SHARED_DAO_COUNTRY_CODE";
const SHARED_DAO_NATIONAL_NUMBER = "SHARED_DAO_NATIONAL_NUMBER";
const SHARED_DAO_DESCRIPTION = "SHARED_DAO_DESCRIPTION";
const SHARED_DAO_EMAIL = "SHARED_DAO_EMAIL";
const SHARED_DAO_PASSWORD = "SHARED_DAO_PASSWORD";
const SHARED_DAO_FIRST_NAME = "SHARED_DAO_FIRST_NAME";
const SHARED_DAO_LAST_NAME = "SHARED_DAO_LAST_NAME";
const SHARED_DAO_USERNAME = "SHARED_DAO_USERNAME";
const SHARED_DAO_ACCESS_TOKEN_KEY = "SHARED_DAO_ACCESS_TOKEN_KEY";
const SHARED_DAO_REFRESH_TOKEN_KEY = "SHARED_DAO_REFRESH_TOKEN_KEY";
const SHARED_DAO_FETCH_ALL_ROOM = "SHARED_DAO_FETCH_ALL_ROOM";
const SHARED_DAO_LOG_LEVEL = "SHARED_DAO_LOG_LEVEL";
const SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED =
    "SHARED_DAO_IS_ALL_NOTIFICATION_DISABLED";
const SHARED_DAO_APP_VERSION = "SHARED_DAO_APP_VERSION";

const ONLINE_TIME = 60000;

const SUPPORTED_IMAGE_EXTENSIONS = ['png', 'jpg', 'jpeg', 'gif'];

// Tables ID
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

// Animation
const ANIMATION_DURATION = const Duration(milliseconds: 100);

// UI
const MAIN_BORDER_RADIUS = 10.0;

const double FLUID_MAX_WIDTH = 400;
const double FLUID_MAX_HEIGHT = 540;

const double FLUID_CONTAINER_MAX_WIDTH = 768;
const double BREAKDOWN_SIZE = 768;

const double NAVIGATION_PANEL_SIZE = 384;

// Screen Breakdown
bool isLargeWidth(double width) => width > BREAKDOWN_SIZE;

bool isLarge(BuildContext context) =>
    isLargeWidth(MediaQuery.of(context).size.width);

// Dynamics
// ignore: non_constant_identifier_names
double animationSquareSize(BuildContext context) => isLarge(context)
    ? min(FLUID_MAX_WIDTH * 0.7, FLUID_MAX_HEIGHT * 0.4)
    : min(MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height * 0.7);

double maxWidthOfMessage(BuildContext context) => min(
    (MediaQuery.of(context).size.width -
            (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) *
        0.7,
    300);
