import 'package:clock/clock.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/widgets/edit_image/change_image_color/color_filter_generator.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:screenshot/screenshot.dart';

class ColorFilterPage extends StatefulWidget {
  final String imagePath;
  final Function(String) onDone;

  const ColorFilterPage({
    super.key,
    required this.imagePath,
    required this.onDone,
  });

  @override
  State<ColorFilterPage> createState() => _ColorFilterPageState();
}

class _ColorFilterPageState extends State<ColorFilterPage> {
  double hueValue = 0;
  double brightnessValue = 0;
  double saturationValue = 0;
  final _fileServices = GetIt.I.get<FileService>();
  final _i18n = GetIt.I.get<I18N>();
  ScreenshotController screenshotController = ScreenshotController();
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: BlurredPreferredSizedWidget(
          child: AppBar(
            backgroundColor: Colors.black.withAlpha(120),
            leading: BackButton(
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              _i18n.get("image_filter"),
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              if (!showLoading)
                IconButton(
                  icon: const Icon(
                    Icons.done_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await _saveImage(context);
                  },
                )
            ],
          ),
        ),
        body: Container(
          color: Colors.black,
          height: double.maxFinite,
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    FittedBox(
                      alignment: FractionalOffset.center,
                      child: Screenshot(
                        controller: screenshotController,
                        child: imageFilterLatest(
                          hue: hueValue,
                          brightness: brightnessValue,
                          saturation: saturationValue,
                          child: ClipRect(
                            child:
                                Image(image: widget.imagePath.imageProvider()),
                          ),
                        ),
                      ),
                    ),
                    if (showLoading)
                      const Center(child: CircularProgressIndicator())
                  ],
                ),
              ),
              if (!showLoading) Column(children: bottomSlider())
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> bottomSlider() {
    return [
      colorFilterSlider(
        onChanged: (v) {
          setState(() {
            hueValue = v;
          });
        },
        value: hueValue,
        sliderLabel: _i18n.get("hue"),
      ),
      const SizedBox(height: 10),
      colorFilterSlider(
        onChanged: (v) {
          setState(() {
            saturationValue = v;
          });
        },
        value: saturationValue,
        sliderLabel: _i18n.get("saturation"),
      ),
      const SizedBox(height: 10),
      colorFilterSlider(
        onChanged: (v) {
          setState(() {
            brightnessValue = v;
          });
        },
        value: brightnessValue,
        sliderLabel: _i18n.get("brightness"),
      ),
      const SizedBox(height: 20),
    ];
  }

  Future<void> _saveImage(BuildContext context) {
    setState(() {
      showLoading = true;
    });

    final navigatorState = Navigator.of(context);

    return screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((binaryIntList) async {
      final outPutFile = await _fileServices.localFile(
        "_filter-${clock.now().millisecondsSinceEpoch}",
        widget.imagePath.split(".").last,
      );
      await outPutFile.writeAsBytes(List<int>.from(binaryIntList!));
      widget.onDone(outPutFile.path);
      navigatorState.pop();
      setState(() {
        showLoading = false;
      });
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

  Widget colorFilterSlider({
    required String sliderLabel,
    required double value,
    required void Function(double)? onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Center(
              child: Text(
                sliderLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
                value: value,
                min: -1,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
