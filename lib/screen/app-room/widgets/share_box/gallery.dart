import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';


import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
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
      {Key key,
      @required this.selectGallery,
      @required this.scrollController,
      @required this.onClick,
      @required this.selectedImages,
      @required this.roomUid })
      : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  AppLocalization appLocalization;
  var _future;

  @override
  void initState() {
    super.initState();
    _future = ImageItem.getImages();
  }

  void cropAvatar(String imagePath) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.square]
            : [
                CropAspectRatioPreset.square,
              ],
        cropStyle: CropStyle.rectangle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: appLocalization.getTraslateValue("avatar"),
            toolbarColor: Colors.blueAccent,
            hideBottomControls: true,
            showCropGrid: false,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: appLocalization.getTraslateValue("avatar"),
        ));
    if (croppedFile != null) {
      widget.onClick(croppedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    return FutureBuilder<List<ImageItem>>(
        future: _future,
        builder: (context, images) {
          if (images.hasData) {
            return GridView.builder(
                controller: widget.scrollController,
                itemCount: images.data.length+1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) {
                  var image = index>0?images.data[index-1]:null;
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
                        icon: Icon(Icons.photo_camera, size: 40),
                        onPressed: () async {
                          try {
                            final picker = ImagePicker();
                            final pickedFile = await picker.getImage(
                                source: ImageSource.camera);
                            widget.selectGallery
                                ? ExtendedNavigator.of(context).push(
                                    Routes.showImagePage,
                                    arguments: ShowImagePageArguments(
                                        imageFile: File(pickedFile.path),
                                        contactUid: widget.roomUid))
                                : cropAvatar(image.path);
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
                                  ExtendedNavigator.of(context).push(
                                      Routes.showImagePage,
                                      arguments: ShowImagePageArguments(
                                          imageFile: File(image.path),
                                          contactUid:widget.roomUid ));
                                } else {
                                  widget.onClick(index, image.path);
                                }
                              }
                            : () {
                                cropAvatar(image.path);
                                Navigator.pop(context);
                              },
                        child: AnimatedPadding(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(selected ? 8.0 : 4.0),
                          child: Hero(
                            tag: image,
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
                                        icon: Icon(selected
                                            ? Icons.check_circle_outline
                                            : Icons.panorama_fish_eye),
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
