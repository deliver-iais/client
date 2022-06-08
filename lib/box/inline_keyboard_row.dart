import 'package:collection/collection.dart';
import 'package:deliver/box/inline_keyboard_button.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'inline_keyboard_row.g.dart';

@HiveType(typeId: INLINE_KEYBOARD_ROW_ID)
class InlineKeyboardRow {
  @HiveField(0)
  List<InlineKeyboardButton> buttons;

  InlineKeyboardRow({
    required this.buttons,
  });

  InlineKeyboardRow copyWith({
    List<InlineKeyboardButton>? buttons,
  }) =>
      InlineKeyboardRow(
        buttons: buttons ?? this.buttons,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other.runtimeType == runtimeType &&
              other is InlineKeyboardRow &&
              const DeepCollectionEquality().equals(other.buttons, buttons));

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(buttons),
  );
}
