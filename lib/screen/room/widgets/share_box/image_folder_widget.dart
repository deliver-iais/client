import 'dart:async';
import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

class ImageFolderWidget extends StatefulWidget {
  final AssetPathEntity folder;
  final Uid roomUid;
  final void Function() pop;
  final void Function(String)? setAvatar;
  final int replyMessageId;
  final void Function()? resetRoomPageDetails;

  const ImageFolderWidget(
    this.folder,
    this.roomUid,
    this.pop, {
    Key? key,
    this.setAvatar,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  }) : super(key: key);

  @override
  State<ImageFolderWidget> createState() => _ImageFolderWidgetState();
}

const int FETCH_IMAGE_PAGE_SIZE = 40;

class _ImageFolderWidgetState extends State<ImageFolderWidget> {
  final List<String> _selectedImage = [];
  final _i18n = GetIt.I.get<I18N>();
  final TextEditingController _textEditingController = TextEditingController();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final Map<String, AssetEntity> _imageFiles = {};

  @override
  void initState() {
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });
    super.initState();
  }

  Future<List<AssetEntity>?> _fetchImage(int index) async {
    var completer =
        _completerMap["image-${(index / FETCH_IMAGE_PAGE_SIZE).floor()}"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["image-${(index / FETCH_IMAGE_PAGE_SIZE).floor()}"] =
        completer;
    final res = await widget.folder.getAssetListPaged(
      page: (index / FETCH_IMAGE_PAGE_SIZE).floor(),
      size: FETCH_IMAGE_PAGE_SIZE,
    );
    completer.complete(res);
    return completer.future;
  }

  Future<AssetEntity?> _getImageAtIndex(int index) async {
    if (index < _imageFiles.values.length) {
      return _imageFiles.values.elementAt(index);
    } else {
      final _images = await _fetchImage(index);
      if (_images != null && _images.isNotEmpty) {
        for (final element in _images) {
          _imageFiles[element.id] = element;
        }
        return _imageFiles.values.elementAt(index);
      }

      return null;
    }
  }

  final _completerMap = <String, Completer<List<AssetEntity>?>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.setAvatar == null && _selectedImage.isNotEmpty)
            IconButton(
              onPressed: () {
                _selectedImage.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear),
            )
        ],
        title: widget.setAvatar == null
            ? Text(
                _selectedImage.isNotEmpty
                    ? "selected: ${_selectedImage.length}"
                    : widget.folder.name,
                style: const TextStyle(fontSize: 19),
              )
            : const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          GridView.builder(
            controller: ScrollController(),
            itemCount: widget.folder.assetCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (c, index) {
              return FutureBuilder<AssetEntity?>(
                future: _getImageAtIndex(index),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return FutureBuilder<File?>(
                      future: snapshot.data!.file,
                      builder: (context, fileSnapshot) {
                        if (fileSnapshot.hasData &&
                            fileSnapshot.data!.existsSync()) {
                          var imagePath = fileSnapshot.data!.path;
                          return GestureDetector(
                            onTap: () {
                              if (widget.setAvatar != null) {
                                widget.pop();
                                Navigator.pop(context);
                                widget.setAvatar!(imagePath);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) {
                                      return OpenImagePage(
                                        imagePath: imagePath,
                                        onEditEnd: (path) {
                                          imagePath = path;
                                        },
                                        sendSingleImage: true,
                                        insertCaption: _insertCaption,
                                        onTap: onTap,
                                        selectedImage: _selectedImage,
                                        send: _send,
                                        pop: widget.pop,
                                        textEditingController:
                                            _textEditingController,
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            child: AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(
                                _selectedImage.contains(imagePath) ? 8.0 : 4.0,
                              ),
                              child: Hero(
                                tag: imagePath,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: secondaryBorder,
                                    image: DecorationImage(
                                      image: Image.file(
                                        File(imagePath),
                                        cacheWidth: 500,
                                        cacheHeight: 500,
                                      ).image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: widget.setAvatar != null
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
                                                    .withOpacity(0.5),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  _selectedImage
                                                          .contains(imagePath)
                                                      ? Icons
                                                          .check_circle_outline
                                                      : Icons.panorama_fish_eye,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
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
              },
            )
        ],
      ),
    );
  }

  void _send() {
    _messageRepo.sendMultipleFilesMessages(
      widget.roomUid,
      _selectedImage.map((e) => model.File(e, e.split(".").last)).toList(),
      replyToId: widget.replyMessageId,
      caption: _textEditingController.text,
    );
    widget.resetRoomPageDetails?.call();
  }

  void onTap(String imagePath) {
    if (widget.setAvatar != null) {
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
}
