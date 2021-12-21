import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final List<Widget>? children;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsList({
    Key? key,
    this.children,
    this.physics,
    this.shrinkWrap = false,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: contentPadding,
      itemCount: children!.length,
      itemBuilder: (context, index) {
        return children![index];
      },
    );
  }
}
