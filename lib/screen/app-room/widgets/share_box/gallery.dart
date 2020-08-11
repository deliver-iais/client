import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class ShareBoxGallery extends StatelessWidget {
  final List<AssetEntity> assets;
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedImages;

  const ShareBoxGallery(
      {Key key, @required this.assets, @required this.scrollController, @required this.onClick, @required this.selectedImages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        itemCount: assets.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
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
                    final pickedFile =
                        await picker.getImage(source: ImageSource.camera);
                    ExtendedNavigator.of(context).push(Routes.showImagePage,
                        arguments: ShowImagePageArguments(
                            imageFile: File(pickedFile.path),
                            contactUid: "Judi"));
                  } catch (e) {}
                },
              ),
            );
          } else {
            var selected = selectedImages[index - 1] ?? false;
            return FutureBuilder<File>(
              future: assets.elementAt(index - 1).file,
              builder: (ctx, snp) {
                if (snp.hasData) {
                  return GestureDetector(
                      onTap: () {
                        ExtendedNavigator.of(context).push(Routes.showImagePage,
                            arguments: ShowImagePageArguments(
                                imageFile: snp.data, contactUid: "Judi"));
                      },
                      child: AnimatedPadding(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(selected ? 8.0 : 4.0),
                        child: Hero(
                          tag: snp.data.path,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(
                                  image: Image.file(snp.data).image, fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () => onClick(index),
                                icon: Icon(selected
                                    ? Icons.check_circle_outline
                                    : Icons.panorama_fish_eye),
                              ),
                            ),
                          ),
                        ),
                      ));
                }
                return Container(width: 50, height: 50);
              },
            );
          }
        });
  }
}
