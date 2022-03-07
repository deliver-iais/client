import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/image_folder_widget.dart';
import 'package:deliver/shared/constants.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import 'helper_classes.dart';

class ShareBoxGallery extends StatefulWidget {
  final ScrollController scrollController;
  final Function? setAvatar;
  final bool selectAvatar;
  final Uid roomUid;
  final Function pop;
  final int replyMessageId;

  const ShareBoxGallery(
      {Key? key,
      required this.selectAvatar,
      required this.scrollController,
      this.setAvatar,
      required this.pop,
      required this.roomUid,
      this.replyMessageId = 0})
      : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _i18n = GetIt.I.get<I18N>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final TextEditingController _captionEditingController =
      TextEditingController();
  final _keyboardVisibilityController = KeyboardVisibilityController();

  late Future<List<StorageFile>> _future;
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late BehaviorSubject<CameraController> _cameraController;
  final BehaviorSubject<bool> _insertCaption = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _future = ImageItem.getImages();
    _keyboardVisibilityController.onChange.listen((event) {
      _insertCaption.add(event);
    });
    _initCamera();

    super.initState();
  }

  _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.max);
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        _cameraController = BehaviorSubject.seeded(_controller);
        setState(() {});
      });
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<List<StorageFile>?>(
          future: _future,
          builder: (context, folders) {
            if (folders.hasData &&
                folders.data != null &&
                folders.data!.isNotEmpty) {
              return GridView.builder(
                  controller: widget.scrollController,
                  itemCount: folders.data!.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (co, index) {
                    StorageFile? folder =
                        index > 0 ? folders.data![index - 1] : null;
                    if (index <= 0) {
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(co).primaryColor,
                          borderRadius: secondaryBorder,
                        ),
                        child: _controller.value.isInitialized
                            ? GestureDetector(
                                onTap: () {
                                  openCamera(() {
                                    widget.pop();
                                    Navigator.pop(context);
                                  });
                                },
                                child: CameraPreview(
                                  _controller,
                                  child: const Icon(Icons.photo_camera,
                                      size: 50, color: Colors.black26),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    } else {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(co, MaterialPageRoute(builder: (c) {
                              return ImageFolderWidget(
                                folder!,
                                widget.roomUid,
                                () {
                                  if (!widget.selectAvatar) {
                                    widget.pop();
                                  }
                                  Navigator.pop(context);
                                },
                                selectAvatar: widget.selectAvatar,
                                setAvatar: widget.setAvatar,
                                replyMessageId: widget.replyMessageId,
                              );
                            }));
                          },
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            child: Hero(
                              tag: folder!.folderName,
                              child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: secondaryBorder,
                                    image: DecorationImage(
                                        image: Image.file(
                                          File(
                                            folder.files.first,
                                          ),
                                          cacheWidth: 300,
                                          cacheHeight: 300,
                                        ).image,
                                        fit: BoxFit.cover),
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
                                          folder.folderName,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                      ))),
                            ),
                          ));
                    }
                  });
            }
            return const SizedBox.shrink();
          }),
    );
  }

  void openCamera(Function pop) {
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return Scaffold(
          body: Stack(
        children: [
          StreamBuilder<CameraController>(
              stream: _cameraController.stream,
              builder: (context, snapshot) {
                return CameraPreview(
                  snapshot.data ?? _controller,
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 15),
              child: IconButton(
                onPressed: () async {
                  XFile file = await _controller.takePicture();
                  if (widget.selectAvatar) {
                    widget.pop();
                    Navigator.pop(context);
                    widget.setAvatar!(file.path);
                  } else {
                    openImage(file, pop);
                  }
                },
                icon: const Icon(
                  Icons.photo_camera,
                  color: Colors.black45,
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
                        _controller.description == _cameras[1]
                            ? _cameras[0]
                            : _cameras[1],
                        ResolutionPreset.max);
                    await _controller.initialize();
                    _cameraController.add(_controller);
                  },
                  icon: const Icon(Icons.flip_camera_ios_outlined),
                  color: Colors.black38,
                  iconSize: 40,
                ),
              ),
            )
        ],
      ));
    }));
  }

  void openImage(XFile file, Function pop) {
    String imagePath = file.path;
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return StatefulBuilder(builder: (con, set) {
        return Scaffold(
            appBar: AppBar(
              actions: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        var res = await cropImage(imagePath);
                        if (res != null) {
                          set(() {
                            imagePath = res;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.crop,
                      ),
                      iconSize: 30,
                    ),
                  ],
                )
              ],
            ),
            body: Stack(
              children: [
                Container(
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
                buildInputCaption(
                    context: con,
                    i18n: _i18n,
                    count: 0,
                    insertCaption: _insertCaption,
                    captionEditingController: _captionEditingController,
                    send: () {
                      pop();
                      Navigator.of(context).pop();
                      _messageRepo.sendFileMessage(
                          widget.roomUid,
                          model.File(imagePath, file.name,
                              extension: file.mimeType),
                          caption: _captionEditingController.text);
                    })
              ],
            ));
      });
    }));
  }
}

Stack buildInputCaption(
    {required BehaviorSubject<bool> insertCaption,
    required I18N i18n,
    required TextEditingController captionEditingController,
    required BuildContext context,
    required Function send,
    required int count}) {
  final theme = Theme.of(context);
  return Stack(
    children: [
      Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          child: Container(
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: i18n.get("caption"),
                hintStyle: const TextStyle(color: Colors.black),
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
              style: const TextStyle(color: Colors.black, fontSize: 17),
              autocorrect: true,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 15,
              controller: captionEditingController,
            ),
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
                boxShadow: [BoxShadow(blurRadius: 20.0, spreadRadius: 0.0)],
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
                              splashColor: Colors.red, // inkwell color
                              child: const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(
                                    Icons.send,
                                    size: 30,
                                    color: Colors.white,
                                  )),
                              onTap: () => send()),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
            ),
            if (count > 0)
              Positioned(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        count.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                  width: 16.0,
                  height: 18.0,
                  decoration: BoxDecoration(
                    // color:theme.dialogBackgroundColor,
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
        ),
      )
    ],
  );
}
