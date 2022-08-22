import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'inline_keyboard_button.g.dart';

@HiveType(typeId: INLINE_KEYBOARD_BUTTON_ID)
class InlineKeyboardButton {
  @HiveField(0)
  String text;
  @HiveField(1)
  String json;

  InlineKeyboardButton({
    required this.text,
    required this.json,
  });

  InlineKeyboardButton copyWith({
    String? text,
    String? json,
  }) =>
      InlineKeyboardButton(
        text: text ?? this.text,
        json: json ?? this.json,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other.runtimeType == runtimeType &&
              other is InlineKeyboardButton &&
              const DeepCollectionEquality().equals(other.text, text) &&
              const DeepCollectionEquality().equals(other.json, json));

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(text),
    const DeepCollectionEquality().hash(json),
  );
}
