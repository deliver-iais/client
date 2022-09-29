import 'package:deliver/screen/show_case/widgets/grouped_banner/grouped_banner_item.dart';
import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_banner/single_banner_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';

class GroupedBanner extends StatelessWidget {
  final GroupedBanners groupedBanner;

  const GroupedBanner({Key? key, required this.groupedBanner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      height: 260,
      title: groupedBanner.name,
      listItemLength: groupedBanner.bannersList.length,
      listItem: (index) => _buildGroupedBannerItem(index, context),
      onArrowButtonPressed: () {},
    );
  }

  Widget _buildGroupedBannerItem(int index, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleBannerWidget(
          bannerCase: groupedBanner.bannersList[index],
          width: 250,
          height: 140,
          padding: 10,
        ),
        GroupedBannerItem(
          uid: groupedBanner.bannersList[index].uid,
        ),
      ],
    );
  }
}
