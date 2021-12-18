import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/share_box/image_folder_widget.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'helper_classes.dart';

class ShareBoxGallery extends StatefulWidget {
  final ScrollController scrollController;
  final Function? setAvatar;
  final bool selectAvatar;
  final Uid roomUid;
  final Function pop;

  const ShareBoxGallery(
      {Key? key,
      required this.selectAvatar,
      required this.scrollController,
      this.setAvatar,
      required this.pop,
      required this.roomUid})
      : super(key: key);

  @override
  _ShareBoxGalleryState createState() => _ShareBoxGalleryState();
}

class _ShareBoxGalleryState extends State<ShareBoxGallery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<StorageFile>> _future;
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  late BehaviorSubject<CameraController> _streamController;

  @override
  void initState() {
    _future = ImageItem.getImages();
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
        _streamController = BehaviorSubject.seeded(_controller);
        setState(() {});
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        //todo
      }
    }
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: _controller.value.isInitialized
                            ? GestureDetector(
                                onTap: () {
                                  openCamera();
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
                                  Navigator.pop(co);
                                },
                                selectAvatar: widget.selectAvatar,
                                setAvatar: widget.setAvatar,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
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
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          folder.folderName,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
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

  void openCamera() {
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return Scaffold(
          body: Stack(
        children: [
          StreamBuilder<CameraController>(
              stream: _streamController.stream,
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
                  widget.pop();
                  Navigator.pop(context);
                  widget.selectAvatar
                      ? widget.setAvatar!(file.path)
                      : showCaptionDialog(
                          roomUid: widget.roomUid,
                          context: context,
                          paths: [file.path],
                          type: file.path.split(".").last);
                },
                icon: const Icon(
                  Icons.photo_camera,
                  color: Colors.blue,
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
                    _streamController.add(_controller);
                  },
                  icon: const Icon(Icons.flip_camera_ios_outlined),
                  color: Colors.blueAccent,
                  iconSize: 40,
                ),
              ),
            )
        ],
      ));
    }));
  }
}
