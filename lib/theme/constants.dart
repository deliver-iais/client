import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

// Constraints
const double BREAKDOWN_SIZE = 600;

const double MAIN_PADDING = 16;

const double FLUID_MAX_WIDTH = 400;
const double FLUID_MAX_HEIGHT = 540;

const ANIMATION_DURATION = const Duration(milliseconds: 100);

// Platform
bool isAndroid() => Platform.isAndroid;

bool isIOS() => Platform.isIOS;

bool isWindows() => Platform.isWindows;

bool isLinux() => Platform.isLinux;

bool isMacOS() => Platform.isMacOS;

bool isDesktop() => Platform.isLinux || Platform.isWindows || Platform.isMacOS;

// Screen Breakdown
bool isLargeWidth(double width) => width > BREAKDOWN_SIZE;

bool isLarge(BuildContext context) =>
    isLargeWidth(MediaQuery.of(context).size.width);

// Dynamics
// ignore: non_constant_identifier_names
double ANIMATION_SQUARE_SIZE(BuildContext context) => isLarge(context)
    ? min(FLUID_MAX_WIDTH * 0.7, FLUID_MAX_HEIGHT * 0.4)
    : min(MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height * 0.7);

// ignore: non_constant_identifier_names
double ANIMATION_TOP_PADDING(BuildContext context) => 40;
