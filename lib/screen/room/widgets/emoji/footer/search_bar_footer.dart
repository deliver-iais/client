import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarFooter extends StatelessWidget {
  final VoidCallback onSearchIconTap;
  final VoidCallback onEmojiDeleted;

  const SearchBarFooter({
    Key? key,
    required this.onSearchIconTap,
    required this.onEmojiDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = IconButton.styleFrom(
      maximumSize: const Size.square(36),
      minimumSize: const Size.square(36),
      fixedSize: const Size.square(36),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.topCenter,
      iconSize: 24,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onInverseSurface,
        boxShadow: [
          BoxShadow(
            color: theme.dividerColor,
            blurRadius: 3.0,
            offset: const Offset(0.0, 0.75),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.up,
        children: [
          const SizedBox(
            width: 10,
          ),
          IconButton(
            style: style,
            onPressed: () => onSearchIconTap(),
            icon: const Icon(CupertinoIcons.search),
          ),
          const Spacer(),
          IconButton(
            style: style,
            onPressed: () => onEmojiDeleted(),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.backspace_outlined,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
