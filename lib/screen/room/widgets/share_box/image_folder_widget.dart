import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/crop_image.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rxdart/rxdart.dart';

class ImageFolderWidget extends StatefulWidget {
  final StorageFile storageFile;
  final Uid roomUid;
  final Function pop;
  final bool selectAvatar;
  final Function? setAvatar;

  const ImageFolderWidget(
    this.storageFile,
    this.roomUid,
    this.pop, {
    Key? key,
    this.selectAvatar = false,
    this.setAvatar,
  }) : super(key: key);

  @override
  State<ImageFolderWidget> createState() => _ImageFolderWidgetState();
}

final _cropperKey = GlobalKey();

class _ImageFolderWidgetState extends State<ImageFolderWidget> {
  final List<String> _selectedImage = [];
  final _i18n = GetIt.I.get<I18N>();
  final TextEditingController _textEditingController = TextEditingController();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          !widget.selectAvatar && _selectedImage.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _selectedImage.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear))
              : const SizedBox.shrink()
        ],
        title: !widget.selectAvatar
            ? Text(
                _selectedImage.isNotEmpty
                    ? "selected: ${_selectedImage.length}"
                    : widget.storageFile.folderName,
                style: const TextStyle(fontSize: 19),
              )
            : const SizedBox.shrink(),
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
                    if (widget.selectAvatar) {
                      widget.pop();
                      Navigator.pop(context);
                      widget.setAvatar!(imagePath);
                    } else {
                      openImage(imagePath, index);
                    }
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
                            borderRadius: secondaryBorder,
                            image: DecorationImage(
                                image: Image.file(
                                  File(imagePath),
                                  cacheWidth: 150,
                                  cacheHeight: 150,
                                ).image,
                                fit: BoxFit.cover),
                          ),
                          child: widget.selectAvatar
                              ? const SizedBox.shrink()
                              : Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      onTap: () => onTap(imagePath),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            color: Theme.of(context)
                                                .hoverColor
                                                .withOpacity(0.5)),
                                        child: Center(
                                          child: Icon(
                                            _selectedImage.contains(imagePath)
                                                ? Icons.check_circle_outline
                                                : Icons.panorama_fish_eye,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      )),
                                )),
                    ),
                  ));
            },
          ),
          if (_selectedImage.isNotEmpty)
            buildInputCaption(
                i18n: _i18n,
                insertCaption: _insertCaption,
                context: context,
                captionEditingController: _textEditingController,
                count: _selectedImage.length,
                send: () {
                  widget.pop();
                  _send();
                })
        ],
      ),
    );
  }

  void _send() {
    _messageRepo.sendMultipleFilesMessages(widget.roomUid,
        _selectedImage.map((e) => model.File(e, e.split(".").last)).toList(),
        caption: _textEditingController.text);
  }

  void onTap(String imagePath) {
    if (widget.selectAvatar) {
      widget.setAvatar!(imagePath);
    } else {
      if (_selectedImage.contains(imagePath)) {
        _selectedImage.remove(imagePath);
      } else {
        _selectedImage.add(imagePath);
      }
      setState(() {});
    }
  }

  void openImage(String imagePath, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return StatefulBuilder(builder: (c, set) {
        return Scaffold(
            appBar: AppBar(
              actions: [
                Row(
                  children: [
                    if (_selectedImage.isNotEmpty)
                      Text(
                        _selectedImage.length.toString(),
                        style: const TextStyle(fontSize: 25),
                      ),
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return CropImage(imagePath, (croppedPass) {
                            print(croppedPass.toString());
                          });
                        }));
                        var res = await cropImage(imagePath);
                        if (res != null) {
                          if (_selectedImage.contains(imagePath)) {
                            _selectedImage.remove(imagePath);
                            _selectedImage.add(res);
                          }
                          set(() {
                            imagePath = res;
                          });
                          setState(() {
                            widget.storageFile.files[index] = res;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.crop,
                      ),
                      iconSize: 35,
                    ),
                    IconButton(
                      onPressed: () {
                        set(() {
                          onTap(imagePath);
                        });
                      },
                      icon: _selectedImage.contains(imagePath)
                          ? const Icon(Icons.check_circle_outline)
                          : const Icon(Icons.panorama_fish_eye),
                      iconSize: 35,
                    )
                  ],
                )
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
                          fit: BoxFit.fill),
                    ),
                  ),
                ),
                if (_selectedImage.isNotEmpty &&
                    _selectedImage.contains(imagePath))
                  buildInputCaption(
                      i18n: _i18n,
                      insertCaption: _insertCaption,
                      context: context,
                      captionEditingController: _textEditingController,
                      count: _selectedImage.length,
                      send: () {
                        widget.pop();
                        Navigator.pop(context);
                        _send();
                      })
              ],
            ));
      });
    }));
  }
}

Future<String?> cropImage(String imagePath) async {
  try {
    // Define a key

    //
    // File? croppedFile = await ImageCropper().cropImage(
    //     sourcePath: imagePath,
    //     aspectRatioPresets: Platform.isAndroid
    //         ? [CropAspectRatioPreset.square]
    //         : [
    //             CropAspectRatioPreset.square,
    //           ],
    //     cropStyle: CropStyle.rectangle,
    //     androidUiSettings: const AndroidUiSettings(
    //         toolbarTitle: "image",
    //         toolbarColor: Colors.blueAccent,
    //         hideBottomControls: true,
    //         showCropGrid: false,
    //         toolbarWidgetColor: Colors.white,
    //         initAspectRatio: CropAspectRatioPreset.original,
    //         lockAspectRatio: false),
    //     iosUiSettings: const IOSUiSettings(
    //       title: "image",
    //     ));
    // if (croppedFile != null) {
    //   return croppedFile.path;
    // }
    return null;
  } catch (e) {
    return e.toString();
  }
}
