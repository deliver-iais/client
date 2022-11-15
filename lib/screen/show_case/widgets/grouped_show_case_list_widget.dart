import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedShowCaseListWidget extends StatelessWidget {
  final String title;
  final bool isAdvertisement;
  final bool isPrimary;
  final VoidCallback? onArrowButtonPressed;
  final bool needArrowIcon;
  final int listItemsLength;
  final Widget Function(int) listItems;
  final double height;
  static final _i18n = GetIt.I.get<I18N>();

  const GroupedShowCaseListWidget({
    Key? key,
    required this.title,
    this.onArrowButtonPressed,
    required this.listItems,
    required this.listItemsLength,
    this.height = 140,
    required this.isAdvertisement,
    required this.isPrimary,
    this.needArrowIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 15, vertical: needArrowIcon ? 0 : 8,),
              child: Row(
                children: [
                  if (isAdvertisement) ...[
                    Text(
                      _i18n.get("ads"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: 5,
                        width: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (needArrowIcon)
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => onArrowButtonPressed?.call(),
              ),
          ],
        ),
        _buildGroupedRoomsList(theme)
      ],
    );
  }

  Widget _buildGroupedRoomsList(ThemeData theme) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: listItemsLength,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          return isPrimary
              ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: tertiaryBorder,
                    ),
                    child: listItems(index),
                  ),
                )
              : listItems(index);
        },
      ),
    );
  }
}
