import 'dart:io';

import 'package:camera/camera.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery_folder.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

class GalleryBox extends StatefulWidget {
  final ScrollController scrollController;
  final Uid roomUid;
  final int replyMessageId;
  final void Function() pop;
  final void Function(String)? setAvatar;
  final void Function()? resetRoomPageDetails;

  const GalleryBox({
    super.key,
    required this.scrollController,
    required this.pop,
    required this.roomUid,
    this.setAvatar,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  });

  @override
  GalleryBoxState createState() => GalleryBoxState();
}

class GalleryBoxState extends State<GalleryBox> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _checkPermissionServices =
      GetIt.I.get<CheckPermissionsService>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _captionEditingController =
      TextEditingController();
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  late BehaviorSubject<CameraController> _cameraController;
  final BehaviorSubject<List<AssetPathEntity>> _folders =
      BehaviorSubject.seeded([]);

  @override
  void initState() {
    _initFolders();

    super.initState();
  }

  Future<void> _initFolders() async {
    if (await checkAccessMediaLocationPermission()) {
      final folders =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      final finalFolders = <AssetPathEntity>[];

      for (final f in folders) {
        if ((await f.assetCountAsync) > 0) {
          finalFolders.add(f);
        }
      }
      _folders.add(finalFolders);
    }
    try {
      if (await _checkPermissionServices.checkCameraRecorderPermission()) {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _controller = CameraController(
            _cameras[0],
            ResolutionPreset.max,
            enableAudio: false,
          );
          return _controller!.initialize().then((_) {
            if (!mounted) {
              return;
            }
            _cameraController = BehaviorSubject.seeded(_controller!);
            setState(() {});
          });
        }
      }
    } catch (_) {}
  }

  Future<bool> checkAccessMediaLocationPermission() async {
    return _checkPermissionServices.checkAccessMediaLocationPermission(
      context: context,
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!(_controller?.value.isInitialized ?? false)) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceVariant,
      body: StreamBuilder<List<AssetPathEntity>?>(
        stream: _folders,
        builder: (context, snap) {
          if (snap.hasData && snap.data != null && snap.data!.isNotEmpty) {
            final folders = snap.data!;

            return GridView.builder(
              controller: widget.scrollController,
              itemCount: folders.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (co, index) {
                final folder = folders[index];
                if (_hasCameraCapacity() && index <= 0) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(co).primaryColor,
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
                    child: _hasCameraCapacity()
                        ? GestureDetector(
                            onTap: () {
                              openCamera(() {
                                Navigator.pop(context);
                              });
                            },
                            child: CameraPreview(
                              _controller!,
                              child: const Icon(
                                Icons.photo_camera,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        co,
                        MaterialPageRoute(
                          builder: (c) {
                            return GalleryFolder(
                              folder,
                              widget.roomUid,
                              () {
                                if (widget.setAvatar == null) {
                                  widget.pop();
                                }
                                Navigator.pop(context);
                              },
                              setAvatar: widget.setAvatar,
                              replyMessageId: widget.replyMessageId,
                              resetRoomPageDetails: widget.resetRoomPageDetails,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: FutureBuilder<List<AssetEntity>>(
                        future: folder.getAssetListPaged(page: 0, size: 2),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Stack(
                              children:
                                  buildGallery(snapshot.data!, folder.name),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Widget> buildGallery(List<AssetEntity> assets, String folderName) {
    final theme = Theme.of(context);

    return <Widget>[
      for (var i = 0; i < assets.length; i++)
        Positioned(
          right: i * 6 + 10,
          top: (1 - i) * 7 + 6,
          child: FutureBuilder<File?>(
            future: assets[i].file,
            builder: (context, fileSnapshot) {
              if (fileSnapshot.hasData && fileSnapshot.data != null) {
                return Container(
                  width: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  height: MediaQuery.of(context).size.width / 2 - 40 - (i * 12),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: secondaryBorder,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 4), // changes position of shadow
                      ),
                    ],
                    image: DecorationImage(
                      image: Image.file(
                        fileSnapshot.data!,
                        cacheWidth: 200,
                        height: ((2 - i) * 10) + 480,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: i == 0
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 6,
                              bottom: 4,
                              left: 6,
                              right: 4,
                            ),
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            decoration: BoxDecoration(
                              borderRadius: secondaryBorder.copyWith(
                                topLeft: Radius.zero,
                                topRight: Radius.zero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.colorScheme.shadow.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(
                                    0,
                                    3,
                                  ), // changes position of shadow
                                ),
                              ],
                              color: theme.colorScheme.onSurfaceVariant,
                              // borderRadius: mainBorder,
                            ),
                            child: Text(
                              folderName,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.surfaceVariant,
                                  ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
    ].reversed.toList();
  }

  bool _hasCameraCapacity() =>
      _controller != null && _controller!.value.isInitialized;

  void openCamera(void Function() pop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  StreamBuilder<CameraController>(
                    stream: _cameraController,
                    builder: (context, snapshot) {
                      final size = MediaQuery.of(context).size;
                      final camera = _cameraController.value.value;
                      var scale = size.aspectRatio * camera.aspectRatio;
                      if (scale < 1) scale = 1 / scale;
                      return Center(
                        child: Transform.scale(
                          scale: scale,
                          child: CameraPreview(
                            snapshot.data ?? _controller!,
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30, right: 15),
                      child: IconButton(
                        onPressed: () async {
                          final navigatorState = Navigator.of(context);
                          final file = await _controller!.takePicture();
                          if (widget.setAvatar != null) {
                            widget.pop();
                            navigatorState.pop();
                            widget.setAvatar!(file.path);
                          } else {
                            openImage(file, pop);
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.camera_fill,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                    ),
                  ),
                  if (_cameras.isNotEmpty && _cameras.length > 1)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, right: 10),
                        child: IconButton(
                          onPressed: () async {
                            _controller = CameraController(
                              _controller!.description == _cameras[1]
                                  ? _cameras[0]
                                  : _cameras[1],
                              ResolutionPreset.max,
                            );
                            await _controller!.initialize();
                            _cameraController.add(_controller!);
                          },
                          icon: const Icon(
                            CupertinoIcons.switch_camera,
                          ),
                          color: Colors.white70,
                          iconSize: 40,
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void openImage(XFile file, void Function() pop) {
    var imagePath = file.path;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return OpenImagePage(
            forceToShowCaptionTextField: true,
            pop: pop,
            send: () {
              _messageRepo.sendFileMessage(
                widget.roomUid,
                model.File(imagePath, file.name, extension: file.mimeType),
                caption: _captionEditingController.text,
              );
            },
            textEditingController: _captionEditingController,
            onEditEnd: (path) {
              imagePath = path;
              Navigator.pop(context);
            },
            imagePath: imagePath,
          );
        },
      ),
    );
  }
}
