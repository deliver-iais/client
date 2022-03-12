import 'dart:io';
import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:deliver/services/file_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class CropImage extends StatefulWidget {
  final String imagePath;
 final Function crop;

  const CropImage(this.imagePath, this.crop, {Key? key}) : super(key: key);

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  late CustomImageCropController controller;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final _fileServices = GetIt.I.get<FileService>();

  MemoryImage? memoryImage;
  final BehaviorSubject<bool> _startCrop = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("crop"),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CustomImageCrop(
                  cropPercentage: 0.9,
                  cropController: controller,
                  image: Image.file(File(widget.imagePath)).image,
                  shape: CustomCropShape.Square,
                ),
                StreamBuilder<bool?>(
                    stream: _startCrop.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data != null && s.data!) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const SizedBox.shrink();
                    })
              ],
            ),
          ),
          StreamBuilder<bool?>(
              stream: _startCrop.stream,
              builder: (c, s) {
                if (s.hasData && s.data != null && !s.data!) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: const Icon(CupertinoIcons.refresh),
                          onPressed: controller.reset),
                      IconButton(
                          icon: const Icon(CupertinoIcons.zoom_in),
                          onPressed: () => controller
                              .addTransition(CropImageData(scale: 1.33))),
                      IconButton(
                          icon: const Icon(CupertinoIcons.zoom_out),
                          onPressed: () => controller
                              .addTransition(CropImageData(scale: 0.75))),
                      IconButton(
                          icon: const Icon(CupertinoIcons.rotate_left),
                          onPressed: () => controller
                              .addTransition(CropImageData(angle: -pi / 4))),
                      IconButton(
                          icon: const Icon(CupertinoIcons.rotate_right),
                          onPressed: () => controller
                              .addTransition(CropImageData(angle: pi / 4))),
                      IconButton(
                        icon: const Icon(CupertinoIcons.crop),
                        onPressed: () async {
                          _startCrop.add(true);
                          final image = await controller.onCropImage();
                          if (image != null) {
                            setState(() {
                              memoryImage = image;
                            });
                            final outPutFile = await _fileServices.localFile(
                                "_crop-${DateTime.now().millisecondsSinceEpoch}",
                                widget.imagePath.split(".").last);
                            outPutFile.writeAsBytesSync(image.bytes);
                            widget.crop(outPutFile.path);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
