import 'package:deliver/shared/methods/file_helpers.dart';

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
    return ExtendedImage(
      image: filePath.imageProvider(),
      mode: ExtendedImageMode.gesture,
      initGestureConfigHandler: (state) => GestureConfig(
          inPageView: true,
          minScale: 1.0,
          maxScale: 4.0,
          reverseMousePointerScrollDirection: true,),
      enableSlideOutPage: true,
      onDoubleTap: (state) => onDoubleTap(state),
    );
  }
}
