import 'dart:io';

import 'package:deliver/shared/methods/platform.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageMediaWidget extends StatelessWidget {
  final String filePath;
  final Function(ExtendedImageGestureState) onDoubleTap;

  const ImageMediaWidget({
    super.key,
    required this.filePath,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return isWeb
        ? Image.network(filePath)
        : ExtendedImage.file(
            File(filePath),
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                inPageView: true,
                minScale: 1.0,
                maxScale: 4.0,
                //you can cache gesture state even though page view page change.
                //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
              );
            },
            enableSlideOutPage: true,
            onDoubleTap: (state) => onDoubleTap(state),
          );
  }
}
