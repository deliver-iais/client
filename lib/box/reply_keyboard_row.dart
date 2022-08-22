import 'package:collection/collection.dart';
import 'package:deliver/box/reply_keyboard_button.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'reply_keyboard_row.g.dart';

@HiveType(typeId: REPLY_KEYBOARD_ROW_ID)
class ReplyKeyboardRow {
  @HiveField(0)
  List<ReplyKeyboardButton> buttons;

  ReplyKeyboardRow({
    required this.buttons,
  });

  ReplyKeyboardRow copyWith({
    List<ReplyKeyboardButton>? buttons,
  }) =>
      ReplyKeyboardRow(
        buttons: buttons ?? this.buttons,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is ReplyKeyboardRow &&
          const DeepCollectionEquality().equals(other.buttons, buttons));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(buttons),
      );
}
