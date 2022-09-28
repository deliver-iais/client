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
      title: groupedBanner.name,
      listItemLength: groupedBanner.bannersList.length,
      listItem: GroupedBannerItem,
      onArrowButtonPressed: () {},
    );
  }

  Widget GroupedBannerItem(int index) {
    return Column(
      children: [
        SingleBannerWidget(bannerCase:groupedBanner.bannersList[index] ),
      ],
    );
  }
}
