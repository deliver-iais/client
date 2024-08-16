import 'dart:async';
import 'dart:io';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/circular_check_mark_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/file_box_item_icon.dart';

import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

const int FETCH_IMAGE_PAGE_SIZE = 30;

class GalleryBox extends StatefulWidget {
  final ScrollController scrollController;
  final Uid? roomUid;
  final int replyMessageId;
  final void Function(String)? onAvatarSelected;
  final void Function()? resetRoomPageDetails;
  final bool selectAsAvatar;

  const GalleryBox({
    super.key,
    required this.scrollController,
    required this.roomUid,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  })  : selectAsAvatar = false,
        onAvatarSelected = null;

  const GalleryBox.setAvatar({
    super.key,
    required this.scrollController,
    this.roomUid,
    this.onAvatarSelected,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  }) : selectAsAvatar = true;

  @override
  GalleryBoxState createState() => GalleryBoxState();
}

class GalleryBoxState extends State<GalleryBox> {
  final _cameraService = GetIt.I.get<CameraService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _checkPermissionServices =
      GetIt.I.get<CheckPermissionsService>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final BehaviorSubject<bool> _canInitCamera = BehaviorSubject.seeded(false);

  final _routingService = GetIt.I.get<RoutingService>();

  final _allImageSize = BehaviorSubject.seeded(0);
  final List<String> _selectedImage = [];
  final Map<String, AssetEntity> _imageFiles = {};

  Future<List<AssetEntity>?> _fetchImage(int index) async {
    var completer =
        _completerMap["image-${(index / FETCH_IMAGE_PAGE_SIZE).floor()}"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["image-${(index / FETCH_IMAGE_PAGE_SIZE).floor()}"] =
        completer;
    final res = await PhotoManager.getAssetListPaged(
      page: (index / FETCH_IMAGE_PAGE_SIZE).floor(),
      pageCount: FETCH_IMAGE_PAGE_SIZE,
      type: RequestType.image,
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
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      if (await checkAccessMediaLocationPermission()) {
        await PhotoManager.requestPermissionExtend();
        _allImageSize
            .add((await PhotoManager.getAssetCount(type: RequestType.image)));
      }
      await _checkPermissionServices.checkCameraRecorderPermission();
      await _cameraService
          .initCamera()
          .then((value) => _canInitCamera.add(value));
    } catch (_) {
      print(_);
    }
  }

  Future<bool> checkAccessMediaLocationPermission() async {
    return _checkPermissionServices.checkAccessMediaLocationPermission(
      context: context,
    );
  }

  @override
  void dispose() {
    _selectedImage.clear();
    _imageFiles.clear();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceVariant,
      body: StreamBuilder(
        stream: MergeStream([_allImageSize, _canInitCamera]),
        builder: (context, snap) {
          final hasCamera = _canInitCamera.value;
          var allImageCount = _allImageSize.value;
          if (allImageCount == 0 && !hasCamera) {
            return const SizedBox.shrink();
          }
          if (hasCamera) {
            allImageCount = allImageCount + 1;
          }
          if (snap.hasData && snap.data != null) {
            return Stack(
              children: [
                GridView.builder(
                  controller: ScrollController(),
                  itemCount: allImageCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (c, index) {
                    if (index == 0) {
                      return Container(
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: secondaryBorder,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (hasCamera) {
                              await _cameraService.enableRecordAudio();
                              _routingService.openCameraBox(
                                selectAsAvatar: widget.selectAsAvatar,
                                roomUid: widget.roomUid,
                                onAvatarSelected: widget.onAvatarSelected,
                              );
                            } else {
                              Timer(const Duration(milliseconds: 800),
                                  () async {
                                if (hasCamera) {
                                  await _cameraService.enableRecordAudio();
                                  _routingService.openCameraBox(
                                    selectAsAvatar: widget.selectAsAvatar,
                                    roomUid: widget.roomUid,
                                    onAvatarSelected: widget.onAvatarSelected,
                                  );
                                }
                              });
                            }
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (hasCamera) _cameraService.buildPreview(),
                              const Center(
                                child: Icon(
                                  CupertinoIcons.camera,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return FutureBuilder<AssetEntity?>(
                      future: _getImageAtIndex(index - 1),
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
                                          widget.onAvatarSelected!(imagePath),
                                        }
                                      : _routingService.openViewImagePage(
                                          imagePath: imagePath,
                                          onEditEnd: (path) {
                                            imagePath = path;
                                            setState(() {});
                                          },
                                          sendSingleImage: true,
                                          onTap: onTap,
                                          selectedImage: _selectedImage,
                                          onSend: (caption, path) {
                                            Navigator.pop(context);
                                            _selectedImage
                                              ..remove(imagePath)
                                              ..add(path);
                                            _sendMessage(caption);
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
                                        child: isVideo(imagePath)
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(
                                                      5.0,
                                                    ), //
                                                  ),
                                                ),
                                                width: 200,
                                                height: 200,
                                                child: Stack(
                                                  children: [
                                                    FileIcon(
                                                      file: fileSnapshot.data!,
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        color: Theme.of(context)
                                                            .highlightColor,
                                                        child: const Icon(
                                                          CupertinoIcons
                                                              .video_camera,
                                                        ),
                                                      ),
                                                    ),
                                                    _buildSelectedButton(
                                                        imagePath, isSelected)
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      secondaryBorder / 2,
                                                  image: DecorationImage(
                                                    image: Image.file(
                                                      File(imagePath),
                                                      cacheWidth: 200,
                                                      cacheHeight: 200,
                                                    ).image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: widget.selectAsAvatar
                                                    ? const SizedBox.shrink()
                                                    : _buildSelectedButton(
                                                        imagePath,
                                                        isSelected,
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
                          _sendMessage(caption);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void onTap(String imagePath) {
    if (_selectedImage.contains(imagePath)) {
      _selectedImage.remove(imagePath);
    } else {
      _selectedImage.add(imagePath);
    }
    setState(() {});
  }

  void _sendMessage(String caption) {
    _messageRepo.sendMultipleFilesMessages(
      widget.roomUid!,
      _selectedImage.toSet().map(pathToFileModel).toList(),
      replyToId: widget.replyMessageId,
      caption: caption,
    );
    widget.resetRoomPageDetails?.call();
  }

  Align _buildSelectedButton(String imagePath, bool isSelected) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        enableFeedback: false,
        onPressed: () {
          onTap(imagePath);
        },
        icon: CircularCheckMarkWidget(
          shouldShowCheckMark: isSelected,
        ),
        iconSize: 27,
      ),
    );
  }
}
