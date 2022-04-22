import 'dart:io';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/widgets/edit_image/Change_image_color/color_filter_generator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:screenshot/screenshot.dart';

class ColorFilterPage extends StatefulWidget {
  final String imagePath;
  final Function(String) onDone;

  const ColorFilterPage({
    Key? key,
    required this.imagePath,
    required this.onDone,
  }) : super(key: key);

  @override
  State<ColorFilterPage> createState() => _ColorFilterPageState();
}

class _ColorFilterPageState extends State<ColorFilterPage> {
  double hueValue = 0;
  double brightnessValue = 0;
  double saturationValue = 0;
  final _fileServices = GetIt.I.get<FileService>();
  ScreenshotController screenshotController = ScreenshotController();
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("image filter"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
            onPressed: () async {
              setState(() {
                showLoading = true;
              });

              await _saveImage(context);
              setState(() {
                showLoading = false;
              });
            },
          )
        ],
      ),
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          children: [
            Expanded(
              child: FittedBox(
                alignment: FractionalOffset.center,
                child: Screenshot(
                  controller: screenshotController,
                  child: imageFilterLatest(
                    hue: hueValue,
                    brightness: brightnessValue,
                    saturation: saturationValue,
                    child: ClipRect(child: Image.file(File(widget.imagePath))),
                  ),
                ),
              ),
            ),
            if (showLoading)
              const CircularProgressIndicator()
            else
              Column(children: bottomSlider())
          ],
        ),
      ),
    );
  }

  List<Widget> bottomSlider() {
    final theme = Theme.of(context);
    return [
      Row(
        children: [
          const SizedBox(width: 100, child: Center(child: Text('Hue'))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: Slider(
                activeColor: theme.primaryColor,
                inactiveColor: Colors.grey,
                value: hueValue,
                min: -10.0,
                max: 10.0,
                onChanged: (v) {
                  setState(() {
                    hueValue = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 100, child: Center(child: Text('Saturation'))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: Slider(
                activeColor: theme.primaryColor,
                inactiveColor: Colors.grey,
                value: saturationValue,
                min: -10.0,
                max: 10.0,
                onChanged: (v) {
                  setState(() {
                    saturationValue = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const SizedBox(width: 100, child: Center(child: Text('Brightness'))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              ),
              child: Slider(
                activeColor: theme.primaryColor,
                inactiveColor: Colors.grey,
                value: brightnessValue,
                onChanged: (v) {
                  setState(() {
                    brightnessValue = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: MediaQuery.of(context).padding.bottom),
    ];
  }

  Future<void> _saveImage(BuildContext context) {
    final navigatorState = Navigator.of(context);

    return screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((binaryIntList) async {
      final outPutFile = await _fileServices.localFile(
        "_filter-${DateTime.now().millisecondsSinceEpoch}",
        widget.imagePath.split(".").last,
      );
      await outPutFile.writeAsBytes(List<int>.from(binaryIntList!));
      widget.onDone(outPutFile.path);
      navigatorState.pop();
    });
  }

  Widget imageFilterLatest({
    required double brightness,
    required double saturation,
    required double hue,
    required Widget child,
  }) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(
        ColorFilterGenerator.brightnessAdjustMatrix(
          value: brightness,
        ),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          ColorFilterGenerator.saturationAdjustMatrix(
            value: saturation,
          ),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(
            ColorFilterGenerator.hueAdjustMatrix(
              value: hue,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
