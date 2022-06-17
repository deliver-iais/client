import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  final Color color;

  const DotWidget({
    super.key,
    this.color = Colors.white70,
  });

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
