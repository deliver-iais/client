import 'package:flutter/material.dart';

class TextDialog extends StatelessWidget {
  const TextDialog({
    Key? key,
    required this.context,
    required this.controller,
    required this.fontSize,
    required this.onFinished,
    required this.color,
  }) : super(key: key);
  final TextEditingController controller;
  final double fontSize;
  final VoidCallback onFinished;
  final Color color;
  final BuildContext context;

  static void show(
    BuildContext context,
    TextEditingController controller,
    double fontSize,
    Color color, {
    required VoidCallback onFinished,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return TextDialog(
          context: context,
          controller: controller,
          fontSize: fontSize,
          onFinished: onFinished,
          color: color,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              child: const Text(
                "done",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                onFinished();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
