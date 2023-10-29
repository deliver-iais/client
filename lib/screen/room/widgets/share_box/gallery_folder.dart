import 'dart:async';
import 'dart:io';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/circular_check_mark_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFolder extends StatefulWidget {
  final AssetPathEntity folder;
  final Uid? roomUid;
  final void Function() pop;
  final void Function(String)? onAvatarSelected;
  final int replyMessageId;
  final bool selectAsAvatar;
  final void Function()? resetRoomPageDetails;

  const GalleryFolder(
    this.folder,
    this.pop, {
    super.key,
    this.roomUid,
    this.onAvatarSelected,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
    this.selectAsAvatar = false,
  });

  @override
  State<GalleryFolder> createState() => _GalleryFolderState();
}

const int FETCH_IMAGE_PAGE_SIZE = 40;

class _GalleryFolderState extends State<GalleryFolder> {
  static final _logger = GetIt.I.get<Logger>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  final List<String> _selectedImage = [];
  final Map<String, AssetEntity> _imageFiles = {};

  @override
  void initState() {
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
      final images = await _fetchImage(index);
      if (images != null && images.isNotEmpty) {
        for (final element in images) {
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
    return WillPopScope(
      onWillPop: () async {
        if (_selectedImage.isNotEmpty) {
          setState(() {
            _selectedImage.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            if (!widget.selectAsAvatar && _selectedImage.isNotEmpty)
              IconButton(
                onPressed: () {
                  _selectedImage.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              )
          ],
          title: !widget.selectAsAvatar
              ? AnimatedSwitchWidget(
                  child: Text(
                    key: ValueKey(_selectedImage.length),
                    _selectedImage.isNotEmpty
                        ? "${_selectedImage.length}"
                        : widget.folder.name,
                    style: const TextStyle(fontSize: 19),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: Stack(
          children: [
            FutureBuilder<int>(
              future: widget.folder.assetCountAsync,
              builder: (context, snapshot) {
                return GridView.builder(
                  controller: ScrollController(),
                  itemCount: snapshot.data,
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
                                final isSelected =
                                    _selectedImage.contains(imagePath);
                                return GestureDetector(
                                  onTap: () => widget.selectAsAvatar
                                      ? {
                                   Navigator.pop(context),
                                    widget.pop(),
                                    widget.onAvatarSelected!(imagePath),}
                                      : _routingService.openViewImagePage(
                                          imagePath: imagePath,
                                          onEditEnd: (path) => imagePath = path,
                                          sendSingleImage: true,
                                          onTap: onTap,
                                          selectedImage: _selectedImage,
                                          onSend: (path) {
                                            Navigator.pop(context);
                                            _sendMessage(path);
                                          },
                                        ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      borderRadius: secondaryBorder,
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                        width: isSelected ? 6 : 0,
                                      ),
                                    ),
                                    child: HeroMode(
                                      enabled: settings.showAnimations.value,
                                      child: Hero(
                                        tag: imagePath,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: secondaryBorder / 2,
                                            image: DecorationImage(
                                              image: Image.file(
                                                File(imagePath),
                                                height: 500,
                                                cacheWidth: 200,
                                                cacheHeight: 200,
                                              ).image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: widget.selectAsAvatar
                                              ? const SizedBox.shrink()
                                              : Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    enableFeedback: false,
                                                    onPressed: () {
                                                      onTap(imagePath);
                                                    },
                                                    icon:
                                                        CircularCheckMarkWidget(
                                                      shouldShowCheckMark:
                                                          isSelected,
                                                    ),
                                                    iconSize: 30,
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
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedScale(
                duration: AnimationSettings.verySlow,
                curve: Curves.easeInOut,
                scale: _selectedImage.isNotEmpty ? 1 : 0,
                child: AnimatedOpacity(
                  duration: AnimationSettings.slow,
                  curve: Curves.easeInOut,
                  opacity: _selectedImage.isNotEmpty ? 1 : 0,
                  child: ShareBoxInputCaption(
                    count: _selectedImage.length,
                    onSend: (caption) {
                      widget.pop();
                      _sendMessage(caption);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage(String caption) {
    widget.pop();
    _messageRepo.sendMultipleFilesMessages(
      widget.roomUid!,
      _selectedImage.map(pathToFileModel).toList(),
      replyToId: widget.replyMessageId,
      caption: caption,
    );
    widget.resetRoomPageDetails?.call();
  }

  void onTap(String imagePath) {
    if (_selectedImage.contains(imagePath)) {
      _selectedImage.remove(imagePath);
    } else {
      _logger.i("imagePath: $imagePath");
      _selectedImage.add(imagePath);
    }
    setState(() {});
  }
}
