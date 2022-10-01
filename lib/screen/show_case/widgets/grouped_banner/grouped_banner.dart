import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner_item.dart';
import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
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
      itemListLength: showCase.groupedBanners.bannersList.length,
      itemList: (index) => _buildGroupedBannerItem(index, context),
      onArrowButtonPressed: () {},
    );
  }

  Widget _buildGroupedBannerItem(int index, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleBannerWidget(
          bannerCase: showCase.groupedBanners.bannersList[index],
          width: 300,
          height: 170,
          padding: 10,
        ),
        GroupedBannerItem(
          uid: showCase.groupedBanners.bannersList[index].uid,
        ),
      ],
    );
  }
}
