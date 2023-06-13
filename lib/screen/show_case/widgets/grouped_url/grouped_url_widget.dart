import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/screen/show_case/widgets/single_url/single_url_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';

const _SHOWCASE_BOX_HEIGHT = 244.0;

class GroupedUrlWidget extends StatelessWidget {
  final Showcase showCase;

  const GroupedUrlWidget({Key? key, required this.showCase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      height: _SHOWCASE_BOX_HEIGHT,
      width: showcaseBoxWidth(),
      isPrimary: showCase.primary,
      isAdvertisement: showCase.isAdvertisement,
      title: showCase.groupedUrl.name,
      listItemsLength: showCase.groupedUrl.urlsList.length,
      listItems: (index) => _buildGroupedUrlsItem(index, context),
      needArrowIcon: false,
    );
  }

  Widget _buildGroupedUrlsItem(int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: p8,
        end: p8,
        bottom: p4,
      ),
      child: SingleUrlWidget(
        urlCase: showCase.groupedUrl.urlsList[index],
        width: showcaseBoxWidth(),
        imageHeight: 170,
      ),
    );
  }
}
