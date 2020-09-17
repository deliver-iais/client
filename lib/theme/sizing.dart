import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

// Platform
bool isMobile() => Platform.isIOS || Platform.isAndroid;

bool isDesktop() => Platform.isLinux || Platform.isWindows || Platform.isMacOS;

bool isAndroid() => Platform.isAndroid;

bool isIOS() => Platform.isIOS;

bool isWindows() => Platform.isWindows;

bool isLinux() => Platform.isLinux;

bool isMacOS() => Platform.isMacOS;

// Constraints
const double MAIN_PADDING = 16;

const double FLUID_MAX_WIDTH = 400;
const double FLUID_MAX_HEIGHT = 540;

// Dynamics
// ignore: non_constant_identifier_names
double ANIMATION_SQUARE_SIZE(BuildContext context) => isDesktop()
    ? min(FLUID_MAX_WIDTH * 0.7, FLUID_MAX_HEIGHT * 0.4)
    : min(MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height * 0.7);

// ignore: non_constant_identifier_names
double ANIMATION_TOP_PADDING(BuildContext context) => 40;
