import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_url/single_url_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';

class GroupedUrlWidget extends StatelessWidget {
  final Showcase showCase;

  const GroupedUrlWidget({Key? key, required this.showCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      height: 320,
      isPrimary: showCase.primary,
      isAdvertisement: showCase.isAdvertisement,
      title: showCase.groupedUrl.name,
      listItemsLength: showCase.groupedUrl.urlsList.length,
      listItems: (index) => _buildGroupedUrlsItem(index),
      needArrowIcon: false,
    );
  }

  Widget _buildGroupedUrlsItem(int index) {
    return SingleUrlWidget(
      urlCase: showCase.groupedUrl.urlsList[index],
      width: 300,
      imageHeight: 170,
      padding: 10,
    );
  }
}
