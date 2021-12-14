import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageFolderWidget extends StatefulWidget {
  final StorageFile storageFile;
  final Uid roomUid;
  final Function pop;

  const ImageFolderWidget(this.storageFile, this.roomUid, this.pop);

  @override
  State<ImageFolderWidget> createState() => _ImageFolderWidgetState();
}

class _ImageFolderWidgetState extends State<ImageFolderWidget> {
  final List<String> _selectedImage = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.pop();
          Navigator.pop(context);
          showCaptionDialog(
              roomUid: widget.roomUid,
              context: context,
              showSelectedImage: true,
              paths: _selectedImage,
              type: widget.storageFile.files.first.toString().split(".").last);
        },
        child: const Icon(
          Icons.send,
        ),
      ),
      appBar: AppBar(
        title: Text(
          _selectedImage.isNotEmpty
              ? "selected: ${_selectedImage.length}"
              : widget.storageFile.folderName,
          style:
              TextStyle(color: ExtraTheme.of(context).textField, fontSize: 19),
        ),
      ),
      body: GridView.builder(
        controller: ScrollController(),
        itemCount: widget.storageFile.files.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (c, index) {
          String imagePath = widget.storageFile.files[index];
          return GestureDetector(
              onTap: () {
                if (_selectedImage.contains(imagePath)) {
                  _selectedImage.remove(imagePath);
                } else {
                  _selectedImage.add(imagePath);
                }
                setState(() {});
              },
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(
                    _selectedImage.contains(imagePath) ? 8.0 : 4.0),
                child: Hero(
                  tag: imagePath,
                  child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        image: DecorationImage(
                            image: Image.file(File(imagePath),cacheWidth:150 ,cacheHeight:150,).image,
                            fit: BoxFit.cover),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            _selectedImage.contains(imagePath)
                                ? _selectedImage.remove(imagePath)
                                : _selectedImage.add(imagePath);
                            setState(() {});
                          },
                          icon: Icon(
                            _selectedImage.contains(imagePath)
                                ? Icons.check_circle_outline
                                : Icons.panorama_fish_eye,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ));
        },
      ),
    );
  }
}
