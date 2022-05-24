import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/image_folder_widget.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/services/check_permissions_service.dart';
import 'package:deliver/shared/constants.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

class ShareBoxGallery extends StatefulWidget {
  final ScrollController scrollController;
  final Uid roomUid;
  final int replyMessageId;
  final void Function() pop;
  final void Function(String)? setAvatar;
  final void Function()? resetRoomPageDetails;

  const ShareBoxGallery({
    Key? key,
    required this.scrollController,
    required this.pop,
    required this.roomUid,
    this.setAvatar,
    this.replyMessageId = 0,
    this.resetRoomPageDetails,
  }) : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _checkPermissionServices = GetIt.I.get<CheckPermissionsService>();
  final TextEditingController _captionEditingController =
      TextEditingController();
  final _keyboardVisibilityController = KeyboardVisibilityController();
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  late BehaviorSubject<CameraController> _cameraController;
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);
  final BehaviorSubject<List<AssetPathEntity>> _folders =
      BehaviorSubject.seeded([]);

  @override
  void initState() {
    _initFolders();
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });

    super.initState();
  }

  Future<void> _initFolders() async {
    if ((await PhotoManager.requestPermissionExtend()).isAuth &&
        await _checkPermissionServices.checkStoragePermission() &&
        await _checkPermissionServices.checkStorage2Permission()) {
      _folders
          .add(await PhotoManager.getAssetPathList(type: RequestType.image));
    }
    try {
      if (await _checkPermissionServices.checkCameraRecorderPermission() &&
          await _checkPermissionServices.checkCameraRecorderPermission()) {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          _controller = CameraController(_cameras[0], ResolutionPreset.max);
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
    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder<List<AssetPathEntity>?>(
        stream: _folders,
        builder: (context, folders) {
          if (folders.hasData &&
              folders.data != null &&
              folders.data!.isNotEmpty) {
            return GridView.builder(
              controller: widget.scrollController,
              itemCount: folders.data!
                      .where((element) => element.assetCount > 0)
                      .length +
                  1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (co, index) {
                final folder = index > 0
                    ? folders.data!
                        .where((element) => element.assetCount > 0)
                        .toList()[index - 1]
                    : null;
                if (index <= 0) {
                  return Container(
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(co).primaryColor,
                      borderRadius: secondaryBorder,
                    ),
                    child:
                        _controller != null && _controller!.value.isInitialized
                            ? GestureDetector(
                                onTap: () {
                                  openCamera(() {
                                    widget.pop();
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
                            return ImageFolderWidget(
                              folder!,
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
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      child: Hero(
                        tag: folder!.name,
                        child: FutureBuilder<List<AssetEntity>>(
                          future: folder.getAssetListPaged(page: 0, size: 1),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: secondaryBorder,
                                  image: DecorationImage(
                                    image: Image.file(
                                      File(
                                        snapshot.data!.first.relativePath! +
                                            "/${snapshot.data!.first.title!}",
                                      ),
                                      cacheWidth: 500,
                                      cacheHeight: 500,
                                    ).image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  widthFactor: 200,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .hoverColor
                                          .withOpacity(0.5),
                                      borderRadius: mainBorder,
                                    ),
                                    child: Text(
                                      folder.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
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

  void openCamera(void Function() pop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return Scaffold(
            body: Stack(
              children: [
                StreamBuilder<CameraController>(
                  stream: _cameraController.stream,
                  builder: (context, snapshot) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(
                        snapshot.data ?? _controller!,
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
            insertCaption: _insertCaption,
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

Stack buildInputCaption({
  required BehaviorSubject<bool> insertCaption,
  required I18N i18n,
  required TextEditingController captionEditingController,
  required BuildContext context,
  required void Function() send,
  required int count,
}) {
  final theme = Theme.of(context);
  return Stack(
    children: [
      Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: theme.backgroundColor,
          child: TextField(
            decoration: InputDecoration(
              hintText: i18n.get("caption"),
              border: InputBorder.none,
              hintStyle: const TextStyle(fontSize: 16),
              suffixIcon: StreamBuilder<bool>(
                stream: insertCaption.stream,
                builder: (c, s) {
                  if (s.hasData && s.data!) {
                    return IconButton(
                      onPressed: () => send(),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 35,
                      ),
                      color: Colors.lightBlue,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            ),
            style: const TextStyle(fontSize: 17),
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 15,
            controller: captionEditingController,
          ),
        ),
      ),
      Positioned(
        right: 15,
        bottom: 20,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                //boxShadow: [BoxShadow(blurRadius: 20.0)],
                shape: BoxShape.circle,
              ),
              child: StreamBuilder<bool>(
                stream: insertCaption.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      !snapshot.data!) {
                    return ClipOval(
                      child: Material(
                        color: theme.primaryColor, // button color
                        child: InkWell(
                          splashColor: theme.primaryColor, // inkwell color
                          child: const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(
                              Icons.send,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => send(),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            if (count > 0)
              Positioned(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.backgroundColor, // border color
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2), // border width
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor, // inner circle color
                      ),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ), // inner content
                    ),
                  ),
                ),
                top: 35.0,
                right: 0.0,
                left: 35,
              ),
          ],
        ),
      )
    ],
  );
}
