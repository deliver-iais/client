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

  @HiveField(1)
  ReplyKeyboardMarkup? replyKeyboardMarkup;

  @HiveField(2)
  bool removeReplyKeyboard;

  MessageMarkup({
    required this.inlineKeyboardMarkup,
    required this.removeReplyKeyboard,
    required this.replyKeyboardMarkup,
  });

  MessageMarkup copyWith({
    InlineKeyboardMarkup? inlineKeyboardMarkup,
    ReplyKeyboardMarkup? replyKeyboardMarkup,
    bool? removeReplyKeyboard,
  }) =>
      MessageMarkup(
        inlineKeyboardMarkup: inlineKeyboardMarkup ?? this.inlineKeyboardMarkup,
        removeReplyKeyboard: removeReplyKeyboard ?? this.removeReplyKeyboard,
        replyKeyboardMarkup: replyKeyboardMarkup ?? this.replyKeyboardMarkup,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MessageMarkup &&
          const DeepCollectionEquality()
              .equals(other.inlineKeyboardMarkup, inlineKeyboardMarkup) &&
          const DeepCollectionEquality().equals(
            other.removeReplyKeyboard,
            removeReplyKeyboard,
          ) &&
          const DeepCollectionEquality()
              .equals(other.replyKeyboardMarkup, replyKeyboardMarkup));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(inlineKeyboardMarkup),
        const DeepCollectionEquality().hash(removeReplyKeyboard),
        const DeepCollectionEquality().hash(replyKeyboardMarkup),
      );

  @override
  String toString() {
    return 'MessageMarkup{inlineKeyboardMarkup: $inlineKeyboardMarkup, removeReplyKeyboard: $removeReplyKeyboard, }';
  }
}
