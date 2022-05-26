import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/shared/widgets/edit_image/change_image_color/color_filter_page.dart';
import 'package:deliver/shared/widgets/edit_image/crop_image/crop_image.dart';
import 'package:deliver/shared/widgets/edit_image/paint_on_image/page/paint_on_image_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class OpenImagePage extends StatefulWidget {
  final String imagePath;
  final List<String>? selectedImage;
  final Function(String)? onTap;
  final Function(String) onEditEnd;
  final Function()? send;
  final bool forceToShowCaptionTextField;
  final Function()? pop;
  final TextEditingController? textEditingController;
  final BehaviorSubject<bool>? insertCaption;
  final bool sendSingleImage;

  const OpenImagePage({
    Key? key,
    this.selectedImage,
    this.onTap,
    this.send,
    this.textEditingController,
    this.insertCaption,
    required this.imagePath,
    this.pop,
    this.sendSingleImage = false,
    required this.onEditEnd,
    this.forceToShowCaptionTextField = false,
  }) : super(key: key);

  @override
  State<OpenImagePage> createState() => _OpenImagePageState();
}

class _OpenImagePageState extends State<OpenImagePage> {
  final _i18n = GetIt.I.get<I18N>();
  late String imagePath;

  @override
  void initState() {
    imagePath = widget.imagePath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 200,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (widget.selectedImage != null &&
                widget.selectedImage!.isNotEmpty)
              Text(
                widget.selectedImage!.length.toString(),
                style: const TextStyle(fontSize: 17),
              ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
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
                },
                icon: const Icon(
                  CupertinoIcons.crop_rotate,
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
                ),
                iconSize: 30,
              ),
            ],
          ),
          if (widget.selectedImage != null)
            IconButton(
              onPressed: () {
                setState(() {
                  widget.onTap!(imagePath);
                });
              },
              icon: widget.selectedImage!.contains(imagePath)
                  ? const Icon(Icons.check_circle_outline)
                  : const Icon(Icons.panorama_fish_eye),
              iconSize: 30,
            ),
          if (widget.send == null)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {
                setState(() {
                  widget.onEditEnd(imagePath);
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Hero(
            tag: imagePath,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.file(
                    File(
                      imagePath,
                    ),
                  ).image,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          if (widget.sendSingleImage || widget.forceToShowCaptionTextField ||
              (widget.selectedImage != null &&
                  widget.selectedImage!.isNotEmpty &&
                  widget.selectedImage!.contains(imagePath)))
            buildInputCaption(
              i18n: _i18n,
              insertCaption: widget.insertCaption!,
              context: context,
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
                if(widget.sendSingleImage && widget.selectedImage == null && widget.selectedImage!.isEmpty){
                  widget.selectedImage!.add(imagePath);
                }

                widget.send!();
              },
            )
        ],
      ),
    );
  }
}
