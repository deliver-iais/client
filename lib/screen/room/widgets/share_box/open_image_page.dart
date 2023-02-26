import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/circular_check_mark_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/edit_image/change_image_color/color_filter_page.dart';
import 'package:deliver/shared/widgets/edit_image/crop_image/crop_image.dart';
import 'package:deliver/shared/widgets/edit_image/paint_on_image/page/paint_on_image_page.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';

class OpenImagePage extends StatefulWidget {
  final String imagePath;
  final List<String>? selectedImage;
  final Function(String)? onTap;
  final Function(String) onEditEnd;
  final Function()? send;
  final bool forceToShowCaptionTextField;
  final Function()? pop;
  final TextEditingController? textEditingController;
  final bool sendSingleImage;

  const OpenImagePage({
    super.key,
    this.selectedImage,
    this.onTap,
    this.send,
    this.textEditingController,
    required this.imagePath,
    this.pop,
    this.sendSingleImage = false,
    required this.onEditEnd,
    this.forceToShowCaptionTextField = false,
  });

  @override
  State<OpenImagePage> createState() => _OpenImagePageState();
}

class _OpenImagePageState extends State<OpenImagePage> {
  static final _i18n = GetIt.I.get<I18N>();

  late String imagePath;

  @override
  void initState() {
    imagePath = widget.imagePath;
    super.initState();
  }

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
            leadingWidth: 200,
            backgroundColor: Colors.black.withAlpha(120),
            leading: Row(
              children: [
                BackButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (widget.selectedImage != null &&
                    widget.selectedImage!.isNotEmpty)
                  Container(
                    alignment: Alignment.center,
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      border: Border.all(width: 2, color: Colors.white),
                    ),
                    child: Text(
                      widget.selectedImage!.length.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  if (isDesktop || isWeb) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) {
                          return CropImage(
                            imagePath,
                            (path) {
                              setState(() {
                                imagePath = path;
                              });
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    final theme = Theme.of(context);
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: imagePath,
                      compressQuality: 100,
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: _i18n.get("cropper"),
                          cropFrameColor: theme.primaryColorDark,
                          toolbarColor: theme.bottomAppBarTheme.color,
                          toolbarWidgetColor: theme.colorScheme.onSurface,
                          activeControlsWidgetColor: theme.primaryColor,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: false,
                        ),
                        IOSUiSettings(
                          title: _i18n.get("cropper"),
                        ),
                      ],
                    );
                    if (croppedFile != null) {
                      setState(() {
                        imagePath = croppedFile.path;
                      });
                    }
                  }
                },
                icon: const Icon(
                  CupertinoIcons.crop_rotate,
                  color: Colors.white,
                ),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) {
                        return PaintOnImagePage(
                          file: File(imagePath),
                          onDone: (path) {
                            setState(() {
                              imagePath = path;
                            });
                          },
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.paintbrush,
                  color: Colors.white,
                ),
                iconSize: 30,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) {
                        return ColorFilterPage(
                          imagePath: imagePath,
                          onDone: (path) {
                            setState(() {
                              imagePath = path;
                            });
                          },
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.slider_horizontal_below_rectangle,
                  color: Colors.white,
                ),
                iconSize: 30,
              ),
              if (widget.selectedImage != null)
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      widget.onTap!(imagePath);
                    });
                  },
                  icon: widget.selectedImage!.contains(imagePath)
                      ? const CircularCheckMarkWidget(
                          shouldShowCheckMark: true,
                        )
                      : const CircularCheckMarkWidget(),
                  iconSize: 30,
                ),
              if (widget.send == null)
                IconButton(
                  icon: const Icon(Icons.done),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      widget.onEditEnd(imagePath);
                    });
                  },
                ),
            ],
          ),
        ),
        body: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Hero(
                tag: imagePath,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imagePath.imageProvider(),
                    ),
                  ),
                ),
              ),
              if (widget.sendSingleImage ||
                  widget.forceToShowCaptionTextField ||
                  (widget.selectedImage != null &&
                      widget.selectedImage!.isNotEmpty &&
                      widget.selectedImage!.contains(imagePath)))
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ShareBoxInputCaption(
                    captionEditingController: widget.textEditingController!,
                    count: widget.selectedImage != null
                        ? widget.selectedImage!.length
                        : 0,
                    send: () {
                      widget.pop!();
                      Navigator.pop(context);
                      setState(() {
                        widget.onEditEnd(imagePath);
                      });
                      if (widget.sendSingleImage &&
                          (widget.selectedImage == null ||
                              widget.selectedImage!.isEmpty)) {
                        widget.selectedImage!.add(imagePath);
                      }
                      widget.send!();
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
