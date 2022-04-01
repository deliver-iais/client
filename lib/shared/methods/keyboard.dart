import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/services.dart';

bool isFunctionalClicked(RawKeyEvent event) =>
    (isMacOS && event.isMetaPressed) ||
    (!isMacOS && event.isControlPressed);

bool isKeyPressed(RawKeyEvent event, PhysicalKeyboardKey key) =>
    event is RawKeyDownEvent && event.physicalKey == key;

bool isMetaAndKeyPressed(RawKeyEvent event, PhysicalKeyboardKey key) =>
    isFunctionalClicked(event) &&
    event is RawKeyDownEvent &&
    event.physicalKey == key;

bool isEnterClicked(RawKeyEvent event) =>
    event is RawKeyDownEvent &&
    (event.physicalKey == PhysicalKeyboardKey.enter ||
        event.physicalKey == PhysicalKeyboardKey.numpadEnter);
