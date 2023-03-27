// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_frame.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindowFrame _$WindowFrameFromJson(Map<String, dynamic> json) => WindowFrame(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      bottom: (json['bottom'] as num).toDouble(),
    );

Map<String, dynamic> _$WindowFrameToJson(WindowFrame instance) =>
    <String, dynamic>{
      'left': instance.left,
      'top': instance.top,
      'right': instance.right,
      'bottom': instance.bottom,
    };
