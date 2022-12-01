import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarFooter extends StatelessWidget {
  final VoidCallback onSearchIconTap;

  const SearchBarFooter({Key? key, required this.onSearchIconTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onInverseSurface,
        boxShadow: [
          BoxShadow(
            color: theme.dividerColor,
            blurRadius: 15.0,
            offset: const Offset(0.0, 0.75),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () => onSearchIconTap(),
            icon: const Icon(CupertinoIcons.search),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.backspace_outlined,
            ),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
