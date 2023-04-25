import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

bool isFunctionalClicked(RawKeyEvent event) =>
    (isMacOSNative && event.isMetaPressed) ||
    (!isMacOSNative && event.isControlPressed);

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

void setKeyBoardSizeInMemoryIfNeeded(BuildContext buildContext) {
  _setKeyBoardSize(
    (bottomOffset) => settings.keyboardSizePortraitInMemory
        .set(bottomOffset,),
    (bottomOffset) => settings.keyboardSizeLandscapeInMemory
        .set(bottomOffset,),
    buildContext,
  );
}

void _setKeyBoardSize(
  Function(double) onKeyboardSizePortraitSet,
  Function(double) onKeyboardSizeLandscapeSet,
  BuildContext buildContext,
) {
  if (hasVirtualKeyboardCapability) {
    final mq = MediaQuery.of(buildContext);
    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
    if (bottomOffset > 0) {
      if (mq.orientation == Orientation.portrait) {
        if (settings.keyboardSizePortrait.value == 0) {
          onKeyboardSizePortraitSet(bottomOffset);
        }
      } else if (settings.keyboardSizeLandscape.value == 0) {
        onKeyboardSizeLandscapeSet(bottomOffset);
      }
    }
  }
}

void setKeyBoardSizeInSharedDaoStorageIfNeeded(BuildContext buildContext) {
  _setKeyBoardSize(
    (bottomOffset) => settings.keyboardSizePortrait.set(bottomOffset),
    (bottomOffset) => settings.keyboardSizeLandscape.set(bottomOffset),
    buildContext,
  );
}

double getKeyboardSizeFromMemory(BuildContext context) {
  final mq = MediaQuery.of(context);
  if (mq.orientation == Orientation.landscape) {
    return settings.keyboardSizeLandscapeInMemory.value;
  } else {
    return settings.keyboardSizePortraitInMemory.value;
  }
}

double getKeyboardSizeFromSharedDao(BuildContext context) {
  final mq = MediaQuery.of(context);
  if (mq.orientation == Orientation.landscape) {
    return settings.keyboardSizeLandscape.value;
  } else {
    return settings.keyboardSizePortrait.value;
  }
}
