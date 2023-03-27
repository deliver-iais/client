import 'package:deliver/shared/constants.dart';
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
    right: FLUID_MAX_WIDTH + 100,
    bottom: FLUID_MAX_HEIGHT + 100,
  );

  @override
  String toString() {
    return "WindowFrame([left:$left],[top:$top],[right:$right],[bottom:$bottom])";
  }
}

const WindowFrameFromJson = _$WindowFrameFromJson;
const WindowFrameToJson = _$WindowFrameToJson;
