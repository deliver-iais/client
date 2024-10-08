import 'package:deliver/box/dao/emoji_skin_tone_dao.dart';
import 'package:deliver/box/dao/recent_emoji_dao.dart';
import 'package:deliver/box/emoji_skin_tone.dart';
import 'package:deliver/fonts/fonts.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// TODO(any): there is some bugs after direction and resizable navigation bar size
class SkinToneOverlay {
  static final _recentEmojisDao = GetIt.I.get<RecentEmojiDao>();
  static final _emojiSkinToneDao = GetIt.I.get<EmojiSkinToneDao>();

  static OverlayEntry getSkinToneOverlay(
    int index,
    Emoji emoji,
    BuildContext context,
    double offset,
    void Function(String) onEmojiSelected,
    VoidCallback? onSkinToneOverlay, {
    bool hideHeaderAndFooter = false,
  }) {
    final positionRect = _calculateEmojiPosition(
      index,
      context,
      offset,
      hideHeaderAndFooter: hideHeaderAndFooter,
    );
    return OverlayEntry(
      builder: (context) => Positioned(
        left: positionRect.left,
        top: positionRect.top,
        child: MouseRegion(
          onHover: (val) {
            onSkinToneOverlay!();
          },
          child: Material(
            elevation: 10,
            borderRadius: tertiaryBorder,
            child: Row(
              children: [
                ...List.generate(
                  FITZPATRICK.values.length,
                  (i) => _buildSkinToneEmoji(
                    i,
                    emoji.toString(),
                    positionRect.width,
                    onEmojiSelected,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Rect _calculateEmojiPosition(
    int index,
    BuildContext context,
    double scrollOffset, {
    bool hideHeaderAndFooter = false,
  }) {
    final columns = Emoji.getColumnsCount(context);
    // Calculate position of emoji in the grid

    final column = index % columns;
    final row =
        (Emoji.byGroup(EmojiGroup.smileysEmotion).length / columns).ceil() +
            (Emoji.recent().length / columns).ceil() +
            (index / columns).ceil() +
            (column == 0 ? 1 : 0);
    // Calculate position for skin tone dialog
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final emojiSpace = renderBox.size.width / columns;
    final topOffset = emojiSpace;
    final leftOffset = _getLeftOffset(
      emojiSpace,
      column,
      FITZPATRICK.values.length,
      columns,
    );
    final left = 600 + offset.dx - column * emojiSpace + leftOffset;
    final top = (hideHeaderAndFooter && hasVirtualKeyboardCapability ? 1 : 2) *
            PERSISTENT_EMOJI_HEADER_HEIGHT +
        (hasVirtualKeyboardCapability ? 15 : 0) +
        offset.dy +
        (row) * emojiSpace -
        scrollOffset -
        topOffset;
    return Rect.fromLTWH(left, top, emojiSpace, 45);
  }

  static Widget _buildSkinToneEmoji(
    int index,
    String emoji,
    double width,
    void Function(String) onEmojiSelected,
  ) {
    final modifyEmoji = Emoji.modify(emoji, FITZPATRICK.values[index]);
    return Material(
      color: Colors.white.withOpacity(0.0),
      child: InkWell(
        borderRadius: tertiaryBorder,
        onTap: () {
          onEmojiSelected(modifyEmoji);
          Emoji.updateSkinTone(emoji, index);
          _recentEmojisDao.addRecentEmoji(emoji, skinToneEmoji: modifyEmoji);
          _emojiSkinToneDao
              .addNewSkinTone(EmojiSkinTone(char: emoji, tone: index));
        },
        child: SizedBox(
          height: width,
          width: width - 10,
          child: Center(
            child: Text(
              modifyEmoji,
              style: emojiFont(fontSize: 25),
            ),
          ),
        ),
      ),
    );
  }

  static double _getLeftOffset(
    double emojiWidth,
    int column,
    int skinToneCount,
    int columns,
  ) {
    final remainingColumns = columns - (column + 1 + (skinToneCount ~/ 2));
    if (column >= 0 && column < 3) {
      return -1 * column * emojiWidth;
    } else if (remainingColumns < 0) {
      return -1 *
          ((skinToneCount ~/ 2 - 2) + -1 * remainingColumns) *
          emojiWidth;
    }
    return -1 * ((skinToneCount ~/ 2) * emojiWidth) + emojiWidth / 2;
  }
}
