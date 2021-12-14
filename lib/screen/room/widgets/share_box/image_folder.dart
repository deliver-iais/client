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
      appBar: AppBar(
        actions: [
          _selectedImage.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _selectedImage.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear))
              : const SizedBox.shrink()
        ],
        title: Text(
          _selectedImage.isNotEmpty
              ? "selected: ${_selectedImage.length}"
              : widget.storageFile.folderName,
          style:
              TextStyle(color: ExtraTheme.of(context).textField, fontSize: 19),
        ),
      ),
      body: Stack(
        children: [
          GridView.builder(
            controller: ScrollController(),
            itemCount: widget.storageFile.files.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
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
                                image: Image.file(
                                  File(imagePath),
                                  cacheWidth: 150,
                                  cacheHeight: 150,
                                ).image,
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
          _selectedImage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 40),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(blurRadius: 20.0, spreadRadius: 0.0)
                              ],
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Material(
                                color: Theme.of(context)
                                    .primaryColor, // button color
                                child: InkWell(
                                    splashColor: Colors.red, // inkwell color
                                    child: const SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Icon(
                                          Icons.send,
                                          size: 30,
                                          color: Colors.white,
                                        )),
                                    onTap: () {
                                      widget.pop();
                                      Navigator.pop(context);
                                      showCaptionDialog(
                                          roomUid: widget.roomUid,
                                          context: context,
                                          showSelectedImage: true,
                                          paths: _selectedImage,
                                          type: widget.storageFile.files.first
                                              .toString()
                                              .split(".")
                                              .last);
                                    }),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    _selectedImage.length.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                              width: 16.0,
                              height: 16.0,
                              decoration: BoxDecoration(
                                // color: Theme.of(context).dialogBackgroundColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.lightBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            top: 35.0,
                            right: 0.0,
                            left: 25,
                          ),
                        ],
                      )),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
