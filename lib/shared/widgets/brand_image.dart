import 'package:flutter/material.dart';

class BrandImage extends StatelessWidget {
  final String imagePath;
  final String text;
  final Alignment alignment;
  final double topFreeHeight;

  const BrandImage({
    Key? key,
    required this.imagePath,
    required this.text,
    this.topFreeHeight = 300,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              alignment: alignment,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0, 0.35],
                colors: [Colors.black45, Colors.transparent],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: topFreeHeight),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0.0, 0.5),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
