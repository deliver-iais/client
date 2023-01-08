import 'package:animate_do/animate_do.dart';
import 'package:deliver/screen/navigation_center/search/recent_result/recent_search_and_room_widget.dart';
import 'package:deliver/screen/navigation_center/search/search_result/search_result_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

class SearchRoomsWidget extends StatefulWidget {
  final TextEditingController searchBoxController;

  const SearchRoomsWidget({Key? key, required this.searchBoxController})
      : super(key: key);

  @override
  State<SearchRoomsWidget> createState() => _SearchRoomsWidgetState();
}

class _SearchRoomsWidgetState extends State<SearchRoomsWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.searchBoxController.text.isNotEmpty) {
      return SlideInUp(
        key: const Key("result"),
        duration: VERY_SLOW_ANIMATION_DURATION,
        child:
            SearchResultWidget(searchBoxController: widget.searchBoxController),
      );
    } else {
      return SlideInUp(
        key: const Key("last_search_result"),
        duration: VERY_SLOW_ANIMATION_DURATION,
        child: const RecentSearchAndRoomWidget(),
      );
    }
  }
}
