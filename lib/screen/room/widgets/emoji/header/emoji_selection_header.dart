import 'package:deliver/screen/room/widgets/emoji/header/persistent_emoji_header.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/emoji.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class EmojiSelectionHeader extends StatelessWidget {
  final bool pinHeader;
  final void Function(int) onEmojiGroupHeaderTap;
  final BehaviorSubject<EmojiGroup?> selectedEmojiGroup;

  const EmojiSelectionHeader({
    Key? key,
    this.pinHeader = true,
    required this.onEmojiGroupHeaderTap,
    required this.selectedEmojiGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius = hasVirtualKeyboardCapability
        ? BorderRadius.zero
        : const BorderRadius.only(
            topRight: Radius.circular(8),
            topLeft: Radius.circular(8),
          );

    return SliverPersistentHeader(
      pinned: _pinHeader(),
      floating: true,
      delegate: PersistentEmojiHeader(
        widget: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: borderRadius,
          ),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: EmojiGroup.values.length,
                  itemBuilder: (c, index) {
                    return buildHeaderItems(theme, index);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderItems(
    ThemeData theme,
    int index,
  ) {
    final emojiGroup = EmojiGroup.values[index];

    return emojiGroup != EmojiGroup.recentEmoji || Emoji.recent().isNotEmpty
        ? StreamBuilder<EmojiGroup?>(
            stream: selectedEmojiGroup,
            builder: (context, snapshot) {
              final isSelected = isSelectedEmojiGroup(emojiGroup);
              return InkWell(
                onTap: () => onEmojiGroupHeaderTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: p8),
                  child: Icon(
                    // size: isSelected ? 26 : 24,
                    Emoji.convertEmojiGroupToIcon(emojiGroup),
                    color: selectionColor(theme, isSelected: isSelected),
                  ),
                ),
              );
            },
          )
        : const SizedBox.shrink();
  }

  Color selectionColor(ThemeData theme, {required bool isSelected}) {
    if (isSelected) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.8);
    }
  }

  bool _pinHeader() {
    if (pinHeader) {
      return true;
    } else {
      return false;
    }
  }

  bool isSelectedEmojiGroup(EmojiGroup emoji) =>
      emoji == selectedEmojiGroup.value;
}
