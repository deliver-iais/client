import 'package:flutter/widgets.dart';

abstract class AbstractSection extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? titlePadding;

  const AbstractSection({Key? key, this.title, this.titlePadding}) : super(key: key);
}
