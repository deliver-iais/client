import 'package:collection/collection.dart';
import 'package:deliver/box/reply_keyboard_row.dart';
import 'package:deliver/shared/constants.dart';

import 'package:hive/hive.dart';

part 'reply_keyboard_markup.g.dart';

@HiveType(typeId: REPLY_KEYBOARD_MARKUP_ID)
class ReplyKeyboardMarkup {
  @HiveField(0)
  List<ReplyKeyboardRow> rows;

  @HiveField(1)
  bool oneTimeKeyboard;

  ReplyKeyboardMarkup({
    required this.rows,
    required this.oneTimeKeyboard,
  });

  ReplyKeyboardMarkup copyWith({
    List<ReplyKeyboardRow>? rows,
    bool? oneTimeKeyboard,
  }) =>
      ReplyKeyboardMarkup(
        rows: rows ?? this.rows,
        oneTimeKeyboard: oneTimeKeyboard ?? this.oneTimeKeyboard,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is ReplyKeyboardMarkup &&
          const DeepCollectionEquality().equals(
            other.rows,
            rows,
          ) &&
          const DeepCollectionEquality()
              .equals(other.oneTimeKeyboard, oneTimeKeyboard));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(rows),
        const DeepCollectionEquality().hash(oneTimeKeyboard),
      );

  @override
  String toString() {
    return 'ReplyKeyboardMarkup{rows: $rows, oneTimeKeyboard: $oneTimeKeyboard}';
  }
}
