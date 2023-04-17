import 'package:deliver/screen/show_case/widgets/ads.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}

class GroupedShowCaseListWidget extends StatelessWidget {
  final String title;
  final bool isAdvertisement;
  final bool isPrimary;
  final VoidCallback? onArrowButtonPressed;
  final bool needArrowIcon;
  final int listItemsLength;
  final Widget Function(int) listItems;
  final double height;
  final double width;

  const GroupedShowCaseListWidget({
    Key? key,
    required this.title,
    this.onArrowButtonPressed,
    required this.listItems,
    required this.listItemsLength,
    required this.height,
    required this.width,
    required this.isAdvertisement,
    required this.isPrimary,
    this.needArrowIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: p8, bottom: p12),
      color: isPrimary
          ? theme.colorScheme.tertiaryContainer
          : theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: isAdvertisement ? p8 : p16,
                  end: p16,
                  top: p8,
                  bottom: needArrowIcon ? 0 : p8,
                ),
                child: Row(
                  children: [
                    if (isAdvertisement) const Ads(),
                    if (isAdvertisement) const SizedBox(width: p4),
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
      ),
    );
  }

  Widget _buildGroupedRoomsList(ThemeData theme) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: SizedBox(
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listItemsLength,
          itemBuilder: (ctx, index) => listItems(index),
        ),
      ),
    );
  }
}
