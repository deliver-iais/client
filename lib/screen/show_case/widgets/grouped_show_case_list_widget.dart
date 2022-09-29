import 'package:flutter/material.dart';

class GroupedShowCaseListWidget extends StatelessWidget {
  final String title;
  final VoidCallback onArrowButtonPressed;
  final int listItemLength;
  final Widget Function(int) listItem;
  final double height;

  const GroupedShowCaseListWidget({
    Key? key,
    required this.title,
    required this.onArrowButtonPressed,
    required this.listItem,
    required this.listItemLength,
    this.height=130,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:MainAxisSize.min ,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => onArrowButtonPressed(),
            ),
          ],
        ),
        _buildGroupedRoomsList()
      ],
    );
  }

  Widget _buildGroupedRoomsList() {
    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: listItemLength,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          return listItem(index);
        },
      ),
    );
  }
}
