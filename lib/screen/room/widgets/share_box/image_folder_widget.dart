import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/edit_image/paint_on_image/page/paint_on_image.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/crop_image.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ImageFolderWidget extends StatefulWidget {
  final StorageFile storageFile;
  final Uid roomUid;
  final Function pop;
  final bool selectAvatar;
  final Function? setAvatar;
  final int replyMessageId;
  final Function? resetRoomPageDetails;

  const ImageFolderWidget(
    this.storageFile,
    this.roomUid,
    this.pop, {
    Key? key,
    this.selectAvatar = false,
    this.setAvatar,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  }) : super(key: key);

  @override
  State<ImageFolderWidget> createState() => _ImageFolderWidgetState();
}

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
        replyToId: widget.replyMessageId, caption: _textEditingController.text);
    if (widget.resetRoomPageDetails != null) {
      widget.resetRoomPageDetails!();
    }
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
              leadingWidth: 200,
              leading: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (_selectedImage.isNotEmpty)
                    Text(
                      _selectedImage.length.toString(),
                      style: const TextStyle(fontSize: 17),
                    ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return CropImage(imagePath, (path) {
                            if (path != null) {
                              set(() {
                                imagePath = path;
                              });
                            }
                          });
                        }));
                      },
                      icon: const Icon(
                        CupertinoIcons.crop_rotate,
                      ),
                      iconSize: 30,
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return PaintOnImage(
                              file: File(imagePath),
                              onDone: (path) {
                                if (path != null) {
                                  set(() {
                                    imagePath = path;
                                  });
                                }
                              });
                        }));
                      },
                      icon: const Icon(
                        CupertinoIcons.paintbrush,
                      ),
                      iconSize: 30,
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (c) {
                          return PaintOnImage(
                              file: File(imagePath),
                              onDone: (path) {
                                if (path != null) {
                                  set(() {
                                    imagePath = path;
                                  });
                                }
                              });
                        }));
                      },
                      icon: const Icon(
                          CupertinoIcons.slider_horizontal_below_rectangle),
                      iconSize: 30,
                    ),
                  ],
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
                  iconSize: 30,
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
                          fit: BoxFit.fitWidth),
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
