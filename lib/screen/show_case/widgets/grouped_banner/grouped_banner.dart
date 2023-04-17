import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner_item.dart';
import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';

const _SHOWCASE_BOX_HEIGHT = 270.0;

class GroupedBanner extends StatelessWidget {
  final Showcase showCase;

  const GroupedBanner({Key? key, required this.showCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      height: _SHOWCASE_BOX_HEIGHT,
      width: showcaseBoxWidth(),
      isPrimary: showCase.primary,
      isAdvertisement: showCase.isAdvertisement,
      title: showCase.groupedBanners.name,
      listItemsLength: showCase.groupedBanners.bannersList.length,
      listItems: (index) => _buildGroupedBannerItem(index, context),
      needArrowIcon: false,
    );
  }

  Widget _buildGroupedBannerItem(int index, BuildContext context) {
    final isLast = index == showCase.groupedBanners.bannersList.length - 1;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: p8,
        end: isLast ? p16 * 2 : p8,
        // This calculation is for some back and force animation bug in last item of list, we should padding at least exactly two time of sum normal padding
        bottom: p2,
      ),
      child: Material(
        elevation: 1,
        borderRadius: secondaryBorder,
        surfaceTintColor: theme.colorScheme.tertiary,
        child: SizedBox(
          width: showcaseBoxWidth(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleBannerWidget(
                bannerCase: showCase.groupedBanners.bannersList[index],
                width: showcaseBoxWidth(),
                height: _SHOWCASE_BOX_HEIGHT - 100 - p2,
              ),
              GroupedBannerItem(
                uid: showCase.groupedBanners.bannersList[index].uid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
