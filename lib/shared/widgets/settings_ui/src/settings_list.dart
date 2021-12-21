import 'package:flutter/material.dart';
import 'abstract_section.dart';

class SettingsList extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final List<AbstractSection>? sections;
  final Color? backgroundColor;
  final Color? lightBackgroundColor;
  final Color? darkBackgroundColor;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsList({
    Key? key,
    this.sections,
    this.backgroundColor,
    this.physics,
    this.shrinkWrap = false,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: contentPadding,
      itemCount: sections!.length,
      itemBuilder: (context, index) {
        return sections![index];
      },
    );
  }
}
