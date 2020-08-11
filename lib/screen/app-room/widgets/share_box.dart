import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';

import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/file.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/helper_classes.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/music.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:storage_path/storage_path.dart';

class ShareBox extends StatefulWidget {
  @override
  _ShareBoxState createState() => _ShareBoxState();
}

enum Page { Gallery, Files, Location, Music }

class _ShareBoxState extends State<ShareBox> {
  final selectedImages = Map<int, bool>();

  final selectedAudio = Map<int, bool>();

  final selectedFiles = Map<int, bool>();

  final finalSelected = Map<int, String>();

  bool selected = false;

  List<FileItem> audioAlbum = new List();
  List<FileItem> files = new List();

  var currentPage = Page.Gallery;

  int selectedItem = 0;

  List<FileItem> _filePathList(String json) {
    List<StorageFile> files = jsonDecode(json)
        .map<StorageFile>((json) => StorageFile.fromJson(json))
        .toList();
    List<FileItem> items = [];
    for (int i = 0; i < files.length; i++) {
      for (int j = 0; j < files[i].files.length; j++) {
        FileItem item = new FileItem(
            path: files[i].files[j]["path"],
            displayName: files[i].files[j]["displayName"],
            artist: files[i].files[j]["artist"],
            title: files[i].files[j]["title"],
            album: files[i].files[j]['album']);
        items.add(item);
      }
    }
    return items;
  }

  Widget CircleButton(Function onTap, IconData icon, String text, double size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipOval(
          child: Material(
            color: Colors.blue, // button color
            child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(width: size, height: size, child: Icon(icon)),
                onTap: onTap),
          ),
        ),
        Text(
          text,
          style:
              TextStyle(fontSize: 10, color: Theme.of(context).backgroundColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetPathEntity>>(
        future: PhotoManager.getAssetPathList(),
        builder: (ctx, snp) {
          if (snp.hasData) {
            return FutureBuilder<List<AssetEntity>>(
              future: snp.data.elementAt(0).assetList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var assets = snapshot.data;
                  return DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    minChildSize: 0.2,
                    maxChildSize: 1,
                    builder: (context, scrollController) {
                      return Container(
                        color: Colors.white,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsetsDirectional.only(
                                    bottom: 80),
                                child: currentPage == Page.Music
                                    ? ShareBoxMusic(
                                        audioAlbum: audioAlbum,
                                        scrollController: scrollController,
                                        onClick: (index) {
                                          setState(() {
                                            selectedAudio[index] =
                                                !(selectedAudio[index] ??
                                                    false);
                                            selectedAudio[index]
                                                ? finalSelected[index] =
                                                    audioAlbum[index].path
                                                : finalSelected
                                                    .remove(audioAlbum[index]);
                                            selectedAudio[index]
                                                ? selectedItem++
                                                : selectedItem--;
                                          });
                                        },
                                        selectedAudio: selectedAudio)
                                    : currentPage == Page.Files
                                        ? ShareBoxFile(
                                            filesList: files,
                                            scrollController: scrollController,
                                            onClick: (index) {
                                              setState(() {
                                                selectedFiles[index] =
                                                    !(selectedFiles[index] ??
                                                        false);
                                                selectedFiles[index]
                                                    ? finalSelected[index] =
                                                        files[index].path
                                                    : finalSelected
                                                        .remove(files[index]);
                                                selectedFiles[index]
                                                    ? selectedItem++
                                                    : selectedItem--;
                                              });
                                            },
                                            selectedFiles: selectedFiles)
                                        : currentPage == Page.Gallery
                                            ? ShareBoxGallery(
                                                assets: assets,
                                                scrollController:
                                                    scrollController,
                                                onClick: (index) async {
                                                  File file =
                                                      await assets[index].file;
                                                  setState(() {
                                                    selectedImages[index - 1] =
                                                        !(selectedImages[
                                                                index - 1] ??
                                                            false);

                                                    selectedImages[index - 1]
                                                        ? finalSelected[index] =
                                                            file.path
                                                        : finalSelected.remove(
                                                            assets[index]);
                                                    selectedImages[index - 1]
                                                        ? selectedItem++
                                                        : selectedItem--;
                                                  });
                                                },
                                                selectedImages: selectedImages,
                                              )
                                            : SizedBox.shrink()),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                selectedItem > 0
                                    ? Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Stack(
                                              children: <Widget>[
                                                CircleButton(
                                                    () {}, Icons.send, "", 50),
                                                Positioned(
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          selectedItem
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                    width: 16.0,
                                                    height: 16.0,
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Colors.blue,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  top: 35.0,
                                                  right: 0.0,
                                                  left: 31,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 30,
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                bottom: 15),
                                        color: Colors.white,
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                CircleButton(() {
                                                  setState(() {
                                                    currentPage = Page.Gallery;
                                                  });
                                                }, Icons.insert_drive_file,
                                                    "Gallery", 40),
                                                CircleButton(() async {
                                                  var filesPathJson =
                                                      await StoragePath
                                                          .filePath;
                                                  setState(() {
                                                    files = _filePathList(
                                                        filesPathJson);
                                                    currentPage = Page.Files;
                                                  });
                                                }, Icons.file_upload, "File",
                                                    40),
                                                CircleButton(
                                                    () async {},
                                                    Icons.location_on,
                                                    "Location",
                                                    40),
                                                CircleButton(() async {
                                                  var audiosPathJson =
                                                      await StoragePath
                                                          .audioPath;
                                                  setState(() {
                                                    audioAlbum = _filePathList(
                                                        audiosPathJson);
                                                    currentPage = Page.Music;
                                                  });

                                                  print(audioAlbum.length
                                                      .toString());
                                                }, Icons.music_note, "Music",
                                                    40),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            );
          }
          return SizedBox.shrink();
        });
  }
}
