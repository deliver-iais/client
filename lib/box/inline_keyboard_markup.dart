import 'package:collection/collection.dart';
import 'package:deliver/box/inline_keyboard_row.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'inline_keyboard_markup.g.dart';

@HiveType(typeId: INLINE_KEYBOARD_MARKUP_ID)
class InlineKeyboardMarkup {
  @HiveField(0)
  List<InlineKeyboardRow> rows;

  InlineKeyboardMarkup({
    required this.rows,
  });

  InlineKeyboardMarkup copyWith({
    List<InlineKeyboardRow>? rows,
  }) =>
      InlineKeyboardMarkup(
        rows: rows ?? this.rows,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is InlineKeyboardRow &&
          const DeepCollectionEquality().equals(other.buttons, rows));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(rows),
      );
}
