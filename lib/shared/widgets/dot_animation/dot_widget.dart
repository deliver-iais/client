import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  final Color color;

  const DotWidget({
    Key? key,
    this.color = Colors.white70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      height: 3,
      width: 3,
    );
  }
}
