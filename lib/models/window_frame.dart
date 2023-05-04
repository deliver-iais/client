import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'window_frame.g.dart';

@JsonSerializable()
class WindowFrame {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const WindowFrame({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  static const defaultInstance = WindowFrame(
    left: 0,
    top: 0,
    right: LARGE_BREAKDOWN_SIZE_WIDTH + 330,
    bottom: LARGE_BREAKDOWN_SIZE_WIDTH,
  );

  static const empty = WindowFrame(
    left: 0,
    top: 0,
    right: 0,
    bottom: 0,
  );

  static const minSize = WindowFrame(
    left: 0,
    top: 0,
    right: FLUID_MAX_WIDTH + 50,
    bottom: FLUID_MAX_HEIGHT + 50,
  );

  Rect toRect() {
    return Rect.fromLTRB(
      left,
      top,
      right,
      bottom,
    );
  }

  Size toSize() {
    return Size(width(), height());
  }

  double width() {
    return right - left;
  }

  double height() {
    return bottom - top;
  }

  @override
  String toString() {
    return "WindowFrame([left:$left],[top:$top],[right:$right],[bottom:$bottom])";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowFrame &&
          runtimeType == other.runtimeType &&
          right == other.right &&
          left == other.left &&
          top == other.top &&
          bottom == other.bottom;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(left),
        const DeepCollectionEquality().hash(right),
        const DeepCollectionEquality().hash(top),
        const DeepCollectionEquality().hash(bottom),
      );
}

const WindowFrameFromJson = _$WindowFrameFromJson;
const WindowFrameToJson = _$WindowFrameToJson;
