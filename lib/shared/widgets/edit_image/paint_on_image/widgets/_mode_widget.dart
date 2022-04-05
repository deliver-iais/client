import 'package:deliver/shared/widgets/edit_image/paint_on_image/_image_painter.dart';
import 'package:flutter/material.dart';

class SelectionItems extends StatelessWidget {
  final bool? isSelected;
  final ModeData? data;
  final VoidCallback? onTap;

  const SelectionItems({Key? key, this.isSelected, this.data, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: isSelected! ? Colors.blue : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(data!.icon, color: isSelected! ? Colors.white : null),
        title: Text(
          data!.label!,
          style: Theme.of(context)
              .textTheme
              .subtitle1!
              .copyWith(color: isSelected! ? Colors.white : null),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        selected: isSelected!,
      ),
    );
  }
}

List<ModeData> paintModes() => [
      const ModeData(
        icon: Icons.zoom_out_map,
        mode: PaintMode.none,
        label: "noneZoom",
      ),
      const ModeData(
        icon: Icons.horizontal_rule,
        mode: PaintMode.line,
        label: "line",
      ),
      const ModeData(
        icon: Icons.crop_free,
        mode: PaintMode.rect,
        label: "rectangle",
      ),
      const ModeData(
        icon: Icons.edit,
        mode: PaintMode.freeStyle,
        label: "drawing",
      ),
      const ModeData(
        icon: Icons.lens_outlined,
        mode: PaintMode.circle,
        label: "circle",
      ),
      const ModeData(
        icon: Icons.arrow_right_alt_outlined,
        mode: PaintMode.arrow,
        label: "arrow",
      ),
      const ModeData(
        icon: Icons.power_input,
        mode: PaintMode.dashLine,
        label: "dashLine",
      ),
      const ModeData(
        icon: Icons.text_format,
        mode: PaintMode.text,
        label: "arrow",
      ),
    ];

@immutable
class ModeData {
  final IconData? icon;
  final PaintMode? mode;
  final String? label;

  const ModeData({
    this.icon,
    this.mode,
    this.label,
  });
}
