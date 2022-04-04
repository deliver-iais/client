import 'package:flutter/material.dart';
class DotWidget extends StatelessWidget {
  const DotWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: Colors.white70,),
      height: 3,
      width: 3,
    );
  }
}