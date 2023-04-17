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
    final isLast = index == showCase.groupedUrl.urlsList.length - 1;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: p8,
        end: isLast ? p16 * 2 : p8,
        // This calculation is for some back and force animation bug in last item of list, we should padding at least exactly two time of sum normal padding
        bottom: p4,
      ),
      child: Material(
        elevation: 2,
        borderRadius: secondaryBorder,
        surfaceTintColor: theme.colorScheme.tertiary,
        child: SingleUrlWidget(
          urlCase: showCase.groupedUrl.urlsList[index],
          width: showcaseBoxWidth(),
          imageHeight: 170,
        ),
      ),
    );
  }
}
