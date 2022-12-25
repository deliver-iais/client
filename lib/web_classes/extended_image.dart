import 'package:flutter/cupertino.dart';

enum ExtendedImageMode {
  gesture,
}

class GestureConfig {
  final dynamic inPageView;
  final dynamic  minScale;
  final dynamic maxScale;

  GestureConfig({
    this.inPageView,
    this.minScale,
    this.maxScale,
  });
}

class ExtendedImageGestureState {
  late final dynamic pointerDownPosition;
  final GestureDetails _gestureDetails;


  ExtendedImageGestureState(this._gestureDetails);

 dynamic  handleDoubleTap({scale, doubleTapPosition}) {}

  GestureDetails? get gestureDetails => _gestureDetails;
}

class GestureDetails {
  final double? totalScale;

  GestureDetails({this.totalScale});
}

class ExtendedImage extends StatelessWidget {
  const ExtendedImage.file(file,
      {super.key, dynamic mode,
      initGestureConfigHandler,
      enableSlideOutPage,
      onDoubleTap});

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
