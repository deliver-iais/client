import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner_item.dart';
import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';

class GroupedBanner extends StatelessWidget {
  final Showcase showCase;

  const GroupedBanner({Key? key, required this.showCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      height: 270,
      isPrimary: showCase.primary,
      isAdvertisement: showCase.isAdvertisement,
      title: showCase.groupedBanners.name,
      listItemsLength: showCase.groupedBanners.bannersList.length,
      listItems: (index) => _buildGroupedBannerItem(index, context, width: 285),
      scrollController: ScrollController(),
      needArrowIcon: false,
    );
  }

  Widget _buildGroupedBannerItem(
    int index,
    BuildContext context, {
    double? width,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: secondaryBorder,
        border: Border.all(color: theme.dividerColor),
      ),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleBannerWidget(
              bannerCase: showCase.groupedBanners.bannersList[index],
              width: 280,
              height: 170,
              padding: 0,
            ),
            GroupedBannerItem(
              uid: showCase.groupedBanners.bannersList[index].uid,
            ),
          ],
        ),
      ),
    );
  }
}
