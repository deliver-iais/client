import 'dart:io';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

import 'helper_classes.dart';

class ShareBoxGallery extends StatefulWidget {
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedImages;
  final bool selectGallery;
  final Uid roomUid;

  const ShareBoxGallery(
      {Key? key,
      required this.selectGallery,
      required this.scrollController,
      required this.onClick,
      required this.selectedImages,
      required this.roomUid})
      : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  var _routingServices = GetIt.I.get<RoutingService>();
  var _future;

  @override
  void initState() {
    _future = ImageItem.getImages();
    super.initState();
  }


  void cropAvatar(String imagePath) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.square]
            : [
                CropAspectRatioPreset.square,
              ],
        cropStyle: CropStyle.rectangle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: i18n.get("avatar"),
            toolbarColor: Colors.blueAccent,
            hideBottomControls: true,
            showCropGrid: false,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: i18n.get("avatar"),
        ));
    if (croppedFile != null) {
      widget.onClick(croppedFile);
    }
  }

  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageItem>?>(
        future: _future,
        builder: (context, images) {
          if (images.hasData &&
              images.data != null &&
              images.data!.length > 0) {
            return GridView.builder(
                controller: widget.scrollController,
                itemCount: images.data!.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  ImageItem? image = index > 0 ? images.data![index - 1] : null;
                  if (index <= 0) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.photo_camera,
                            color: Colors.white, size: 40),
                        onPressed: () async {
                          try {
                            Navigator.pop(context);
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                                source: ImageSource.camera);
                            widget.selectGallery
                                ? _routingServices.openImagePage(context,
                                    roomUid: widget.roomUid,
                                    file: File(pickedFile!.path))
                                : cropAvatar(image!.path);
                          } catch (e) {}
                        },
                      ),
                    );
                  } else {
                    var selected = widget.selectedImages[index - 1] ?? false;
                    return GestureDetector(
                        onTap: widget.selectGallery
                            ? () {
                                if (!widget.selectedImages
                                    .containsValue(true)) {
                                  Navigator.pop(context);
                                  _routingServices.openImagePage(context,
                                      roomUid: widget.roomUid,
                                      file: File(image!.path));
                                } else {
                                  widget.onClick(index, image!.path);
                                }
                              }
                            : () {
                                cropAvatar(image!.path);
                                Navigator.pop(context);
                              },
                        child: AnimatedPadding(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(selected ? 8.0 : 4.0),
                          child: Hero(
                            tag: image!,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                image: DecorationImage(
                                    image: Image.file(File(image.path)).image,
                                    fit: BoxFit.cover),
                              ),
                              child: widget.selectGallery
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () =>
                                            widget.onClick(index, image.path),
                                        icon: Icon(
                                          selected
                                              ? Icons.check_circle_outline
                                              : Icons.panorama_fish_eye,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ));
                  }
                });
          }
          return SizedBox.shrink();
        });
  }
}
