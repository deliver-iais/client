import 'package:collection/collection.dart';

import 'package:deliver/shared/constants.dart';

import 'package:hive/hive.dart';

part 'reply_keyboard_button.g.dart';

@HiveType(typeId: REPLY_KEYBOARD_BUTTON_ID)
class ReplyKeyboardButton {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool sendOnClick;

  ReplyKeyboardButton({
    required this.text,
    required this.sendOnClick,
  });

  ReplyKeyboardButton copyWith({
    String? text,
    bool? sendOnClick,
  }) =>
      ReplyKeyboardButton(
        text: text ?? this.text,
        sendOnClick: sendOnClick ?? this.sendOnClick,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is ReplyKeyboardButton &&
          const DeepCollectionEquality().equals(other.text, text) &&
          const DeepCollectionEquality().equals(
            other.sendOnClick,
            sendOnClick,
          ));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(text),
        const DeepCollectionEquality().hash(sendOnClick),
      );
}
