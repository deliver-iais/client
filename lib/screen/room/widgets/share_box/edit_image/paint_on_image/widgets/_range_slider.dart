import 'package:deliver/screen/room/widgets/share_box/edit_image/paint_on_image/_paint_over_image.dart';
import 'package:flutter/material.dart';

///
class RangedSlider extends StatelessWidget {
  ///Range Slider widget for strokeWidth
  const RangedSlider(
      {Key? key, this.value, this.onChanged, required this.controller})
      : super(key: key);

  ///Default value of strokewidth.
  final double? value;

  /// Callback for value change.
  final ValueChanged<double>? onChanged;

  final ValueNotifier<Controller> controller;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: controller.value.color,
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 15,
        thumbColor: controller.value.color,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayColor: controller.value.color.withAlpha(100),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18.0),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Slider.adaptive(
          max: 40,
          min: 2,
          divisions: 19,
          value: value!,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
