import 'package:collection/collection.dart';
import 'package:deliver/box/inline_keyboard_markup.dart';
import 'package:deliver/box/reply_keyboard_markup.dart';
import 'package:deliver/shared/constants.dart';

import 'package:hive/hive.dart';

part 'message_markup.g.dart';

@HiveType(typeId: MESSAGE_MARK_UP_ID)
class MessageMarkup {
  @HiveField(0)
  InlineKeyboardMarkup? inlineKeyboardMarkup;

  @HiveField(3)
  List<String> inputSuggestions;

  @HiveField(4)
  String inputFieldPlaceHolder;

  MessageMarkup({
    required this.inlineKeyboardMarkup,
    required this.inputFieldPlaceHolder,
    required this.inputSuggestions,
  });

  MessageMarkup copyWith({
    InlineKeyboardMarkup? inlineKeyboardMarkup,
    bool? removeReplyKeyboard,
    String? inputFieldPlaceHolder,
    List<String>? inputSuggestions,
  }) =>
      MessageMarkup(
        inlineKeyboardMarkup: inlineKeyboardMarkup ?? this.inlineKeyboardMarkup,
        inputFieldPlaceHolder:
            inputFieldPlaceHolder ?? this.inputFieldPlaceHolder,
        inputSuggestions: inputSuggestions ?? this.inputSuggestions,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MessageMarkup &&
          const DeepCollectionEquality()
              .equals(other.inlineKeyboardMarkup, inlineKeyboardMarkup) &&
          const DeepCollectionEquality()
              .equals(other.inputSuggestions, inputSuggestions) &&
          const DeepCollectionEquality()
              .equals(other.inputFieldPlaceHolder, inputFieldPlaceHolder));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(inlineKeyboardMarkup),
        const DeepCollectionEquality().hash(inputFieldPlaceHolder),
        const DeepCollectionEquality().hash(inputSuggestions),
      );

  @override
  String toString() {
    return 'MessageMarkup{inlineKeyboardMarkup: $inlineKeyboardMarkup }';
  }
}
